Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 31D216B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 19:09:22 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id r10so7376772pdi.32
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 16:09:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.166])
        by mx.google.com with SMTP id mi5si12023783pab.280.2013.11.04.16.09.20
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 16:09:21 -0800 (PST)
Date: Mon, 4 Nov 2013 16:09:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] percpu: add test module for various percpu
 operations
Message-Id: <20131104160918.0c571b410cf165e9c4b4a502@linux-foundation.org>
In-Reply-To: <1382895017-19067-2-git-send-email-gthelen@google.com>
References: <1382895017-19067-1-git-send-email-gthelen@google.com>
	<1382895017-19067-2-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, 27 Oct 2013 10:30:15 -0700 Greg Thelen <gthelen@google.com> wrote:

> Tests various percpu operations.

Could you please take a look at the 32-bit build (this is i386):

lib/percpu_test.c: In function 'percpu_test_init':
lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
lib/percpu_test.c:112: warning: integer constant is too large for 'long' type

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
