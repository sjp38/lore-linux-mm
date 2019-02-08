Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19E4AC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 23:14:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA22A218D2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 23:14:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA22A218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 543748E00A1; Fri,  8 Feb 2019 18:14:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CCA68E009D; Fri,  8 Feb 2019 18:14:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 397148E00A1; Fri,  8 Feb 2019 18:14:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E97A48E009D
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 18:14:44 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so3923913pfe.10
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 15:14:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=g88Bao/QB3wUSN0EGrB7HANPbINpC8PqoUGXLiW37Is=;
        b=eq13uWPJ6N1L++kwChZMGWIGwmjhlUS4pP3WwJXkAArP5nhwiylqcx/ju5SISND9Op
         xDwTrz1Ph0KvN6qIAgLiozoKYGzXh5K7vWBShv2QPyjHhKRzFIatY3CRXgbgS3tx1/lL
         fNyBk6EnOpT1Xluw8MJqy4EnsLo3pbEZwtgYQwAn+BfGcjEM8ebMG3LZn2MZsseddFCv
         Zh/8nI65YHoDC7jA3gdAGNSP1bZ1PMEmGfI8F43JQDPJ8zkNEEezLPAQ27m1A2A9MY1s
         9sCXoZEYZcdCISxrt8sZQv7WHfd9qCwP8iNxxN8GAjDvA+fhFMJT+ulfrx+22Pnh+xT2
         i5LA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYxkFF+FR5IUG+nW/wAWbEMSFAoixoTrdSL77uMV+E82sEZ541A
	G0Byd3mjdl7FiT8YBNvL06Jf3bxQl8IBPhbwaOSbtlHvKKlqTMjFlUeaO2oIQodivaQNNCiqnkb
	Y6jc+YmBB8OnAJyP4MgTfS1J+bSKjBJSqkNQce+MmxHAwreIyFIZc9RBYYlyPzvKwew==
X-Received: by 2002:a63:bd51:: with SMTP id d17mr23010324pgp.443.1549667684556;
        Fri, 08 Feb 2019 15:14:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IadYJejQZrls8cW+FPJKAWlFv7nGfYxtlGr9borkIDeKnRnoqh9toBmCU75Kvwtnmn0wdAt
X-Received: by 2002:a63:bd51:: with SMTP id d17mr23010245pgp.443.1549667683522;
        Fri, 08 Feb 2019 15:14:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549667683; cv=none;
        d=google.com; s=arc-20160816;
        b=mgC/foNYWVi4YujmoI42whWlq44Qh5Qq+bRxL62xXs4jgeGRbhhIjQz6PieY6QZNO2
         KCE7SxX5CEquOvfv4PKMmgnkM1+Xq5Tnna5Z7Iz88VLSh77KMJ2LWO54GnunXZn5Icfd
         K0g9Q1WeYoX8beS/8rL6y92KC8g0OEcagS2ElL3LCwK/NNEPaEP5SLJFEw6BTAnp9TGX
         QOwy9UwmOz7oeIGH8rSMJFSy8G/oixGMGi/K7yrHXmPGe6pLmB3oiH8wbQ1S8BGoF2lD
         MzBNLJRYciIZK/QQSaKOLG7C16gZGWiZSVvhLU2diQ5/Ju6T8eFd3inhHDdmtnrFggm5
         x0gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=g88Bao/QB3wUSN0EGrB7HANPbINpC8PqoUGXLiW37Is=;
        b=bfGBlXvGfvYXwxYJOzG22iGw4bEyT11W3fUgPvHPo1m+HbFHfGRmlRxiQsAJMxCQ75
         HZZcN5SFKJiT06GQRHUx0QEz2CrqlRS4/BC2MJ6mveX6sViHTiQajkj+vO6DKMtDEzed
         yBBkRsk1hrYjwLx1R3ya/wj5mVEIIukCDjxcAddEVIVuewQ/57XGEYjNoWnXkzB8Gdxk
         FEZER+awgqts9WYJR7hRb2G9zY4n3YE4kkz2OlPY8XIX4SsQCS7eHF2PtdEHXxVX/LVx
         v9JF0eNK6aeh0Iko03HAqD6Ip37/bZq5J14sERTXECVwtYhf+4cLSdEdTm+07bah1oBX
         y6vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1si3532057ply.409.2019.02.08.15.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 15:14:43 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E037CCA00;
	Fri,  8 Feb 2019 23:14:42 +0000 (UTC)
Date: Fri, 8 Feb 2019 15:14:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Suren Baghdasaryan <surenb@google.com>, kbuild-all@01.org, Johannes
 Weiner <hannes@cmpxchg.org>, Linux Memory Management List
 <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Message-Id: <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
In-Reply-To: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2019 02:29:33 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   1bd831d68d5521c01d783af0275439ac645f5027
> commit: e7acbba0d6f7a24c8d24280089030eb9a0eb7522 [6618/6917] psi: introduce psi monitor
> reproduce:
>         # apt-get install sparse
>         git checkout e7acbba0d6f7a24c8d24280089030eb9a0eb7522
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
> 
> All errors (new ones prefixed by >>):
> 
>    kernel/sched/psi.c:151:6: sparse: warning: symbol 'psi_enable' was not declared. Should it be static?
> >> kernel/sched/psi.c:1230:13: sparse: error: incompatible types in comparison expression (different address spaces)
>    kernel/sched/psi.c:774:30: sparse: warning: dereference of noderef expression
> 
> vim +1230 kernel/sched/psi.c
> 
>   1222	
>   1223	static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
>   1224	{
>   1225		struct seq_file *seq = file->private_data;
>   1226		struct psi_trigger *t;
>   1227		__poll_t ret;
>   1228	
>   1229		rcu_read_lock();
> > 1230		t = rcu_dereference(seq->private);
>   1231		if (t)
>   1232			ret = psi_trigger_poll(t, file, wait);
>   1233		else
>   1234			ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
>   1235		rcu_read_unlock();
>   1236	
>   1237		return ret;
>   1238	

Well a bit of googling led me to this fix:

--- a/kernel/sched/psi.c~psi-introduce-psi-monitor-fix-fix
+++ a/kernel/sched/psi.c
@@ -1227,7 +1227,7 @@ static __poll_t psi_fop_poll(struct file
 	__poll_t ret;
 
 	rcu_read_lock();
-	t = rcu_dereference(seq->private);
+	t = rcu_dereference_raw(seq->private);
 	if (t)
 		ret = psi_trigger_poll(t, file, wait);
 	else

But I have no idea why this works, nor what's going on in there. 
rcu_dereference_raw() documentation is scant.

Paul, can you please shed light?

