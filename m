Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 05AE16B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:25:51 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so3655934pad.8
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:25:51 -0800 (PST)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
        by mx.google.com with ESMTPS id ui8si8046298pac.206.2014.01.30.14.25.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 14:25:51 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so3694013pab.33
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:25:50 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <20140130135111.cffc7d8852dd38545bddeb75@linux-foundation.org>
References: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org>
 <1391116318-17253-2-git-send-email-sebastian.capella@linaro.org>
 <20140130132251.4f662aeddc09d8410dee4490@linux-foundation.org>
 <20140130214545.18296.69349@capellas-linux>
 <20140130135111.cffc7d8852dd38545bddeb75@linux-foundation.org>
Message-ID: <20140130222547.19524.88444@capellas-linux>
Subject: Re: [PATCH v5 1/2] mm: add kstrimdup function
Date: Thu, 30 Jan 2014 14:25:47 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

I tested it and saw it working for those cases.

In my comments earlier, I thought Joe was underrunning the buffer, but =

that wasn't the case.

I like Joe's version better as there's no trick there and it is clearer.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
