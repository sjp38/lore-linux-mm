Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id C30206B0039
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:24:07 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id la4so531731vcb.5
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:24:07 -0700 (PDT)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id dr2si266139vdb.78.2014.07.22.14.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 14:24:07 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id hu12so544637vcb.0
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:24:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140722172609.GI6462@pd.tnic>
References: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
	<1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
	<20140721084737.GA10016@pd.tnic>
	<3908561D78D1C84285E8C5FCA982C28F32870C55@ORSMSX114.amr.corp.intel.com>
	<20140721214116.GC11555@pd.tnic>
	<3908561D78D1C84285E8C5FCA982C28F32871435@ORSMSX114.amr.corp.intel.com>
	<20140722172609.GI6462@pd.tnic>
Date: Tue, 22 Jul 2014 14:24:06 -0700
Message-ID: <CA+8MBbJ3BLXwquF6kktmUOWdXRt_=yQha2GL5R8zFVzLo4O-gg@mail.gmail.com>
Subject: Re: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE context
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Chen, Gong" <gong.chen@linux.intel.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Jul 22, 2014 at 10:26 AM, Borislav Petkov <bp@alien8.de> wrote:
> Once they've been eaten by something, we simply remove them from that
> buffer and that's it.

swap that for

Once everyone who registered a notifier as had a chance to see each
logged entry, we simply remove ...

I'm not a fan of the current NOTIFY_STOP behavior where one registrant
can say they are so important that nobody else should be allowed to see
what was logged.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
