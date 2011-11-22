Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EFA136B00AB
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 17:13:25 -0500 (EST)
Date: Tue, 22 Nov 2011 17:13:21 -0500
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: block: initialize request_queue's numa node during allocation
Message-ID: <20111122221320.GB17543@redhat.com>
References: <4ECB5C80.8080609@redhat.com>
 <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com>
 <20111122152739.GA5663@redhat.com>
 <20111122211954.GA17120@redhat.com>
 <alpine.DEB.2.00.1111221342320.2621@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111221342320.2621@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jens Axboe <axboe@kernel.dk>, Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Tue, Nov 22 2011 at  4:45pm -0500,
David Rientjes <rientjes@google.com> wrote:

> Also, your changelog is inadequate since it doesn't convey that his should 
> be merged for 3.2 because it fixes an oops when there is no node 0!

Also, this isn't new to 3.2, v2 should Cc: stable@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
