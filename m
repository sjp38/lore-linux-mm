Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 8862D6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 19:31:50 -0400 (EDT)
Date: Tue, 26 Jun 2012 16:31:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v4 6/6] fault-injection: add notifier error injection
 testing scripts
Message-Id: <20120626163147.93181e21.akpm@linux-foundation.org>
In-Reply-To: <1340463502-15341-7-git-send-email-akinobu.mita@gmail.com>
References: <1340463502-15341-1-git-send-email-akinobu.mita@gmail.com>
	<1340463502-15341-7-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>

On Sat, 23 Jun 2012 23:58:22 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> This adds two testing scripts with notifier error injection

Can we move these into tools/testing/selftests/, so that a "make
run_tests" runs these tests?

Also, I don't think it's appropriate that "fault-injection" be in the
path - that's an implementation detail.  What we're testing here is
memory hotplug, pm, cpu hotplug, etc.  So each test would go into, say,
tools/testing/selftests/cpu-hotplug.

Now, your cpu-hotplug test only tests a tiny part of the cpu-hotplug
code.  But it is a start, and creates the place where additional tests
will be placed in the future.


If the kernel configuration means that the tests cannot be run, the
attempt should succeed so that other tests are not disrupted.  I guess
that printing a warning in this case is useful.

Probably the selftests will require root permissions - we haven't
really thought about that much.  If these tests require root (I assume
they do?) then a sensible approach would be to check for that and to
emit a warning and return "success".

My overall take on the fault-injection code is that there has been a
disappointing amount of uptake: I don't see many developers using them
for whitebox testing their stuff.  I guess this patchset addresses
that, in a way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
