Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 980736B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 22:48:35 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id t19so1524671igi.0
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 19:48:35 -0800 (PST)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id bs7si28044930icc.92.2014.03.03.19.48.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 19:48:34 -0800 (PST)
Received: by mail-ie0-f182.google.com with SMTP id y20so4333671ier.41
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 19:48:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1403011858040.14057@nuc>
References: <20140227073258.GA11087@meta-silence.Home> <alpine.DEB.2.10.1403011858040.14057@nuc>
From: Zhan Jianyu <nasa4836@gmail.com>
Date: Tue, 4 Mar 2014 11:47:52 +0800
Message-ID: <CAHz2CGXmw24CMw8MqRRFJdYgHywJayHGYp5wK=uTyF-goqPeBA@mail.gmail.com>
Subject: Re: [PATCH] mm/slab.c: cleanup outdated comments and unify variables naming
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, penberg@kernel.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Mar 2, 2014 at 8:59 AM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 27 Feb 2014, Jianyu Zhan wrote:
>
>> As time goes, the code changes a lot, and this leads to that
>> some old-days comments scatter around , which instead of faciliating
>> understanding, but make more confusion. So this patch cleans up them.
>
> Acked-by: Christoph Lameter <cl@linux.com>


Thanks, Christoph Lameter.




--

Regards,
Zhan Jianyu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
