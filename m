Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 190968E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 17:00:01 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so35669024pfi.21
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 14:00:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 31si7950381plj.244.2019.01.03.13.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 14:00:00 -0800 (PST)
Date: Thu, 3 Jan 2019 13:59:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [bug] problems with migration of huge pages with
 v4.20-10214-ge1ef035d272e
Message-Id: <20190103135957.68d1ef31f4e125a1a67bbcb9@linux-foundation.org>
In-Reply-To: <6e341052-fe38-b71c-ebb2-47e2e34f5963@oracle.com>
References: <1323128903.93005102.1546461004635.JavaMail.zimbra@redhat.com>
	<6e608107-e071-90c0-bd73-4215325433c1@oracle.com>
	<dc056866-0e60-6ffa-54d5-5cafa1a4a53f@oracle.com>
	<1808265696.93134171.1546519652798.JavaMail.zimbra@redhat.com>
	<495081357.93179893.1546535169172.JavaMail.zimbra@redhat.com>
	<6e341052-fe38-b71c-ebb2-47e2e34f5963@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, kirill shutemov <kirill.shutemov@linux.intel.com>, ltp@lists.linux.it, mhocko@kernel.org, Rachel Sibley <rasibley@redhat.com>, hughd@google.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, dave@stgolabs.net, prakash sangappa <prakash.sangappa@oracle.com>, colin king <colin.king@canonical.com>

On Thu, 3 Jan 2019 13:44:20 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Do I simply send a 'revert'
> patch to you and the list?

Probably that would be best, to give us a changelog, to make sure that
the correct things are reverted and so we have something which you
tested.
