Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 350C26B0037
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 20:27:47 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so2494637pbb.39
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 17:27:46 -0800 (PST)
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
        by mx.google.com with ESMTPS id r7si4469471pbk.87.2014.01.29.17.27.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 17:27:46 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id p10so2419906pdj.3
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 17:27:46 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <alpine.LRH.2.02.1401292001320.9013@file01.intranet.prod.int.rdu2.redhat.com>
References: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org>
 <1391039304-3172-2-git-send-email-sebastian.capella@linaro.org>
 <alpine.LRH.2.02.1401291956510.8304@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1401292001320.9013@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <20140130012742.2769.69633@capellas-linux>
Subject: Re: [PATCH v4 1/2] mm: add kstrimdup function
Date: Wed, 29 Jan 2014 17:27:42 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi Mikulas,

The function body is really verbatim from Andrew's email, as I couldn't
think of any good improvements to add to it.  I'm not sure how best to
credit it to him.

I appreciate you looking it over so carefully.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
