Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 29B426B0074
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 02:21:06 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so743549pdj.10
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 23:21:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id go11si11314047pbd.9.2014.09.17.23.21.04
        for <linux-mm@kvack.org>;
        Wed, 17 Sep 2014 23:21:05 -0700 (PDT)
Message-ID: <541A79CB.4040706@intel.com>
Date: Wed, 17 Sep 2014 23:20:59 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <20140916075007.GA22076@chicago.guarana.org> <9E0BE1322F2F2246BD820DA9FC397ADE017B32C6@shsmsx102.ccr.corp.intel.com> <20140918032334.GA26560@chicago.guarana.org> <541A62DD.7080502@intel.com> <20140918071741.GA29963@chicago.guarana.org>
In-Reply-To: <20140918071741.GA29963@chicago.guarana.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Easton <kevin@guarana.org>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 09/18/2014 12:17 AM, Kevin Easton wrote:
> I was assuming that if an application did want to enable MPX after threads
> had already been created, it would generally want to enable it
> simultaneously across all threads.  This would be a lot easier for the
> kernel than for the application.

The current gcc setup mechanism would set up MPX even before main().  So
I think it's pretty unlikely that help is needed to coordinate threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
