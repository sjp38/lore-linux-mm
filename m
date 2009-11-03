Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9EC536B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 09:14:37 -0500 (EST)
Date: Tue, 3 Nov 2009 12:14:23 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 03/11] Handle asynchronous page fault in a PV guest.
Message-ID: <20091103141423.GC10084@amt.cnet>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-4-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1257076590-29559-4-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 01, 2009 at 01:56:22PM +0200, Gleb Natapov wrote:
> Asynchronous page fault notifies vcpu that page it is trying to access
> is swapped out by a host. In response guest puts a task that caused the
> fault to sleep until page is swapped in again. When missing page is
> brought back into the memory guest is notified and task resumes execution.

Can't you apply this to non-paravirt guests, and continue to deliver
interrupts while waiting for the swapin? 

It should allow the guest to schedule a different task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
