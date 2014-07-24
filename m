Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C495B6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 21:04:59 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so2584014pdb.17
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:04:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id td4si4220495pac.62.2014.07.23.18.04.58
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 18:04:58 -0700 (PDT)
Message-ID: <53D05BA9.1040108@intel.com>
Date: Wed, 23 Jul 2014 18:04:41 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 09/10] x86, mpx: cleanup unused bound tables
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com> <1405921124-4230-10-git-send-email-qiaowei.ren@intel.com> <53CFE4F9.3000701@intel.com> <9E0BE1322F2F2246BD820DA9FC397ADE01703006@shsmsx102.ccr.corp.intel.com>
In-Reply-To: <9E0BE1322F2F2246BD820DA9FC397ADE01703006@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/23/2014 05:49 PM, Ren, Qiaowei wrote:
> I can check a lot of debug information when one VMA and related
> bounds tables are allocated and freed through adding a lot of print()
> like log into kernel/runtime. Do you think this is enough?

I thought the entire reason we grabbed a VM_ flag was to make it
possible to figure out without resorting to this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
