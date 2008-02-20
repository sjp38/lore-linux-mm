Received: by el-out-1112.google.com with SMTP id z25so1245214ele.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 00:29:21 -0800 (PST)
Message-ID: <fd87b6160802200029q6b94311eq78fc4f2d7ab147d4@mail.gmail.com>
Date: Wed, 20 Feb 2008 17:29:21 +0900
From: "John McCabe-Dansted" <gmatht@gmail.com>
Subject: Re: [linux-mm-cc] Announce: ccache release 0.1
In-Reply-To: <4cefeab80802200012r39b00beera521935d141b966a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
	 <4cefeab80802200012r39b00beera521935d141b966a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta910@gmail.com>
Cc: linux-mm-cc@laptop.org, linux-mm@kvack.org, linuxcompressed-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 5:12 PM, Nitin Gupta <nitingupta910@gmail.com> wrote:
>  This project has now moved to: http://code.google.com/p/compcache/
>
>  This was done to avoid confusion with http://ccache.samba.org/ which
>
> has nothing to do with this project.
>
>  PS: only user visible change done is that virtual swap device is now
>  called /dev/compcache

You haven't updated the README file, fortunately
   sed s/ccache/compcache/g < README > README.new
 seems to do exactly what you want.

Perhaps for the convenience of your users you could also include
swapon_compcache.sh:

#!/bin/sh
#Ubuntu Hardy does include lzo_compress and lzo_decompress
(modprobe lzo_compress || insmod
./sub-projects/compression/lzo-kmod/lzo1x_compress.ko) &&
(modprobe lzo_decompress || insmod
./sub-projects/compression/lzo-kmod/lzo1x_decompress.ko) &&
insmod ./sub-projects/allocators/tlsf-kmod/tlsf.ko &&
insmod ./compcache.ko &&
#insmod ./compcache.ko compcache_size_kbytes=128000 &&
sleep 1 &&
swapon /dev/compcache
lsmod | grep lzo
lsmod | grep tlsf
lsmod | grep cache

And swapoff_compcache.sh:

#!/bin/sh
swapoff /dev/ccache
swapoff /dev/compcache
rmmod ccache
rmmod compcache
rmmod tlsf
rmmod lzo1x_compress
rmmod lzo_compress
rmmod lzo1x_decompress
rmmod lzo_decompress

-- 
John C. McCabe-Dansted
PhD Student
University of Western Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
