From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] recursive pagetables for x86 PAE
Date: Sat, 14 Jun 2003 13:27:48 +0200
References: <1055540875.3531.2581.camel@nighthawk>
In-Reply-To: <1055540875.3531.2581.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306141327.48649.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Am Freitag, 13. Juni 2003 23:47 schrieb Dave Hansen:
> When you have lots of tasks, the pagetables start taking up lots of
> lowmem.  We have the ability to push the PTE pages into highmem, but
> that exacts a penalty from the atomic kmaps which, depending on
> workload, can be a 10-15% performance hit.
>
> The following patches implement something which we like to call UKVA.
> It's a Kernel Virtual Area which is private to a process, just like
> Userspace.  You can put any process-local data that you want in the
> area.  But, for now, I just put PTE pages in there.

If you put only such pages there, do you really want that memory to
be per task? IMHO it should be per memory context to aid threading
performance.

Secondly, doesn't this scream for using large pages?

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
