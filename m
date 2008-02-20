Received: by wa-out-1112.google.com with SMTP id m33so4117301wag.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 00:12:46 -0800 (PST)
Message-ID: <4cefeab80802200012r39b00beera521935d141b966a@mail.gmail.com>
Date: Wed, 20 Feb 2008 13:42:45 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: Announce: ccache release 0.1
In-Reply-To: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm-cc@laptop.org
Cc: linuxcompressed-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 3:09 AM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> Hi All,
>
> I am excited to announce first release of ccache - Compressed RAM
> based swap device for Linux (2.6.x kernel).
>   - Project home: http://code.google.com/p/ccache/
>   - ccache-0.1: http://ccache.googlecode.com/files/ccache-0.1.tar.bz2


This project has now moved to: http://code.google.com/p/compcache/

This was done to avoid confusion with http://ccache.samba.org/ which
has nothing to do with this project.

PS: only user visible change done is that virtual swap device is now
called /dev/compcache

- Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
