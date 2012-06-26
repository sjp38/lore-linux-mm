Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 04C4E6B005C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 19:58:16 -0400 (EDT)
Date: Tue, 26 Jun 2012 19:58:04 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [linux-pm] [PATCH -v4 6/6] fault-injection: add notifier error
 injection testing scripts
Message-ID: <20120626235804.GA7525@redhat.com>
References: <1340463502-15341-1-git-send-email-akinobu.mita@gmail.com>
 <1340463502-15341-7-git-send-email-akinobu.mita@gmail.com>
 <20120626163147.93181e21.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626163147.93181e21.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, linux-pm@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jun 26, 2012 at 04:31:47PM -0700, Andrew Morton wrote:

 > My overall take on the fault-injection code is that there has been a
 > disappointing amount of uptake: I don't see many developers using them
 > for whitebox testing their stuff.  I guess this patchset addresses
 > that, in a way.

I added support for make-it-fail to my syscall fuzzer a while ago.
(if the file exists, the child processes set it before calling the fuzzed syscall).
I've not had a chance to really play with it, because I find enough problems
already even without it.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
