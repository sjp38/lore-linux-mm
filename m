Date: Tue, 11 Nov 2008 11:32:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
Message-Id: <20081111113247.c2b0f1ac.akpm@linux-foundation.org>
In-Reply-To: <4919DA7F.5090106@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<20081111103051.979aea57.akpm@linux-foundation.org>
	<4919D370.7080301@redhat.com>
	<20081111111110.decc0f06.akpm@linux-foundation.org>
	<4919DA7F.5090106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008 21:18:23 +0200
Izik Eidus <ieidus@redhat.com> wrote:

> > hm.
> >
> > There has been the occasional discussion about idenfifying all-zeroes
> > pages and scavenging them, repointing them at the zero page.  Could
> > this infrastructure be used for that?  (And how much would we gain from
> > it?)
> >
> > [I'm looking for reasons why this is more than a muck-up-the-vm-for-kvm
> > thing here ;) ]

^^ this?

> KSM is separate driver , it doesn't change anything in the VM but adding 
> two helper functions.

What, you mean I should actually read the code?   Oh well, OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
