Date: Fri, 28 Nov 2008 13:51:25 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v2
Message-ID: <20081128135125.1ee31684@lxorguk.ukuu.org.uk>
In-Reply-To: <m33ahcc8kh.fsf@dmon-lap.sw.ru>
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
	<m33ahcc8kh.fsf@dmon-lap.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitri Monakhov <dmonakhov@openvz.org>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net
List-ID: <linux-mm.kvack.org>

> You have implemented second one, but seems it already was patented
> http://www.google.com/patents?vid=USPAT6789156
> I'm not a lawyer but IMHO we have direct conflict here.
> >From other point of view they have patented the WEEL, but at least we
> have to know about this.

Its an old idea and appeared for Linux in March 1998: Little project from
Philipp Reisner called "mergemem".

http://groups.google.com/group/muc.lists.linux-kernel/browse_thread/thread/387af278089c7066?ie=utf-8&oe=utf-8&q=share+identical+pages#b3d4f68fb5dd4f88

so if there is a patent which is relevant (and thats a question for
lawyers and legal patent search people) perhaps the Linux Foundation and
some of the patent busters could take a look at mergemem and
re-examination.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
