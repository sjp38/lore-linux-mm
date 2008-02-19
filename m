Received: by wx-out-0506.google.com with SMTP id h31so1867601wxd.11
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 02:33:27 -0800 (PST)
Message-ID: <fd87b6160802190233q7a6b95ecrff29ca70a9927e3b@mail.gmail.com>
Date: Tue, 19 Feb 2008 19:33:27 +0900
From: "John McCabe-Dansted" <gmatht@gmail.com>
Subject: Re: [linux-mm-cc] Announce: ccache release 0.1
In-Reply-To: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta910@gmail.com>
Cc: linux-mm-cc@laptop.org, linux-mm@kvack.org, linuxcompressed-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 6:39 AM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> Some performance numbers for allocator and de/compressor can be found
> on project home. Currently it is tested on Linux kernel 2.6.23.x and
> 2.6.25-rc2 (x86 only). Please mail me/mailing-list any
> issues/suggestions you have.

It caused Gutsy (2.6.22-14-generic) to crash when I did a swap off of
my hdd swap. I have a GB of ram, so I would have been fine without
ccache.

I had swapped on a 400MB ccache swap.

BTW, why is the default 10% of mem? This refers to the size of the
block device right? So even 100% would probably only use 50% of
physical memory for swap, assuming a 2:1 compression ratio.

-- 
John C. McCabe-Dansted
PhD Student
University of Western Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
