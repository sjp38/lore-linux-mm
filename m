Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 895D26B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 00:17:06 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so7839488pab.11
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 21:17:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fr9si26735785pdb.239.2014.09.15.21.17.04
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 21:17:05 -0700 (PDT)
Message-ID: <5417B9BE.1030209@intel.com>
Date: Mon, 15 Sep 2014 21:17:02 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>	<1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <20140915010025.5940c946@alan.etchedpixels.co.uk> <9E0BE1322F2F2246BD820DA9FC397ADE017AE183@shsmsx102.ccr.corp.intel.com>
In-Reply-To: <9E0BE1322F2F2246BD820DA9FC397ADE017AE183@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 09/15/2014 08:20 PM, Ren, Qiaowei wrote:
>> What are the semantics across execve() ?
>> 
> This will not impact on the semantics of execve(). One runtime
> library
> for MPX will be provided (or merged into Glibc), and when the
> application starts, this runtime will be called to initialize MPX
> runtime environment, including calling prctl() to notify the kernel to
> start managing the bounds directories. You can see the discussion
> about exec(): https://lkml.org/lkml/2014/1/26/199

I think he's asking what happens to the kernel value at execve() time.

The short answer is that it is zero'd along with the rest of a new mm.
It probably _shouldn't_ be, though.  It's actually valid to have a bound
directory at 0x0.  We probably need to initialize it to -1 instead, and
that means initializing to -1 at execve() time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
