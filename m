Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD5316B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:27:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j12so3444522pff.18
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:27:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q8si3680421pgs.203.2018.03.15.09.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 09:27:58 -0700 (PDT)
Date: Thu, 15 Mar 2018 12:27:53 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/8] Uprobe: Export vaddr <-> offset conversion
 functions
Message-ID: <20180315122753.258c38df@vmware.local.home>
In-Reply-To: <20180313125603.19819-2-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-2-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On Tue, 13 Mar 2018 18:25:56 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> No functionality changes.

Please add a detailed explanation why this patch is needed. All commits
should be self sufficient and stand on their own. If I were to come up
to this patch via a git blame, I would be clueless to why it was done.

-- Steve


> 
> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
> ---
>
