Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 93ADC6B000E
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 00:27:01 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id e53so1126231eek.40
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 21:27:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
References: <512B677D.1040501@oracle.com> <CAHGf_=rur29gFs9R9AYeDwnbVBm3b3cOfAn2xyi=mQ+ZbgzEDA@mail.gmail.com>
 <512C15F0.6030907@oracle.com> <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 28 Feb 2013 00:26:39 -0500
Message-ID: <CAHGf_=r5oo+N0_BSd-8-GPeburBnHVAjLEszmNkj+ASMJXqYLQ@mail.gmail.com>
Subject: Re: mm: BUG in mempolicy's sp_insert
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Insert new node after updating node in tree.

Thanks. you are right. I could reproduce and verified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
