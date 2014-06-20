Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 852876B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 10:24:41 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so3177243qac.25
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:24:41 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id mg8si10717379qcb.30.2014.06.20.07.24.39
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 07:24:39 -0700 (PDT)
Date: Fri, 20 Jun 2014 09:24:36 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: kernel BUG at /src/linux-dev/mm/mempolicy.c:1738! on v3.16-rc1
In-Reply-To: <20140619215641.GA9792@nhori.bos.redhat.com>
Message-ID: <alpine.DEB.2.11.1406200923220.10271@gentwo.org>
References: <20140619215641.GA9792@nhori.bos.redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 19 Jun 2014, Naoya Horiguchi wrote:

> I'm suspecting that mbind_range() do something wrong around vma handling,
> but I don't have enough luck yet. Anyone has an idea?

Well memory policy data corrupted. This looks like you were trying to do
page migration via mbind()? Could we get some more details as to what is
going on here? Specifically the parameters passed to mbind would be
interesting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
