From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14126.56728.207245.91983@dukat.scot.redhat.com>
Date: Tue, 4 May 1999 12:44:24 +0100 (BST)
Subject: Re: Hello
In-Reply-To: <003101be93da$75c98fd0$c80c17ac@clmsdev.local>
References: <003101be93da$75c98fd0$c80c17ac@clmsdev.local>
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 1 May 1999 15:56:46 +0200, "Manfred Spraul"
<manfreds@colorfullife.com> said:

> Do you have any details about PSE-36?

Yes, the PDF docsets on Intel's developer pages cover it pretty well.

> This seems to be a page table extention for the Xeon CPU's
> AFAIK, this is not identical to PAE (available since PPro).

There are two separate extensions.  Since PPro, the CPUs have
supported large page tables.  Currently these can address 36 bits of
physical memory, but given that you have to deal with it in 4MB or 2MB
chunks, it is much less convenient than normal addressing and cannot
easily be used to support transparently the existing kernel
behaviour. 

The newer addressing mode is the 3-level page tables available in
PIIIs (and in later stepping PIIs, I think), which allow transparent
access to all of physical memory up to 64G.  That's what I'm aiming
for.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
