Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 0B4AA6B009B
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 16:41:21 -0400 (EDT)
Date: Tue, 3 Jul 2012 13:41:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v5 0/6] notifier error injection
Message-Id: <20120703134120.dc89c7ae.akpm@linux-foundation.org>
In-Reply-To: <1341035970-20490-1-git-send-email-akinobu.mita@gmail.com>
References: <1341035970-20490-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, Michael Ellerman <michael@ellerman.id.au>, Dave Jones <davej@redhat.com>

On Sat, 30 Jun 2012 14:59:24 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> This provides kernel modules that can be used to test the error handling
> of notifier call chain failures by injecting artifical errors to the
> following notifier chain callbacks.

No updates to Documentation/fault-injection/?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
