Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6BAF66B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 07:56:53 -0400 (EDT)
Date: Mon, 4 Jun 2012 14:56:50 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: kvm segfaults and bad page state in 3.4.0
Message-ID: <20120604115650.GH23670@redhat.com>
References: <20120604114603.GA6988@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120604114603.GA6988@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 04, 2012 at 07:46:03PM +0800, Fengguang Wu wrote:
> Hi,
> 
> I'm running lots of kvm instances for doing kernel boot tests.
> Unfortunately the test system itself is not stable enough, I got scary
> errors in both kvm and the host kernel. Like this. 
> 
What do you mean by "in both kvm and the host kernel". Do you have
similar Oopses inside your guests? If yes can you post one?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
