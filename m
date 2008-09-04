Received: by wr-out-0506.google.com with SMTP id c30so184947wra.14
        for <linux-mm@kvack.org>; Thu, 04 Sep 2008 15:14:46 -0700 (PDT)
Message-ID: <29495f1d0809041514y8cb4764h11aacd3a78cec58d@mail.gmail.com>
Date: Thu, 4 Sep 2008 15:14:46 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
In-Reply-To: <20080904202212.GB26795@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080904202212.GB26795@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 9/4/08, Gary Hade <garyhade@us.ibm.com> wrote:
> Show memory section to node relationship in sysfs
>
>  Add /sys/devices/system/memory/memoryX/node files to show
>  the node on which each memory section resides.

I think this patch needs an additional bit for Documentation/ABI
(might be other parts of /sys/devices/system/memory missing from
there).

Also, I wonder if it might not make more sense to use a symlink here? That is

/sys/devices/system/memory/memoryX/node -> /sys/devices/system/node/nodeY ?

And then we could, potentially, have symlinks returning from the node
side to indicate all memory sections on that node (might be handy for
node offline?):

/sys/devices/system/node/nodeX/memory1 -> /sys/devices/system/memory/memoryY
/sys/devices/system/node/nodeX/memory2 -> /sys/devices/system/memory/memoryZ

Dunno, the latter probably should be a separate patch, but does seem
more like the sysfs behavior (and the number (node or memory section)
should be easily obtained from the symlinks via readlink, as opposed
to cat with the current patch?).

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
