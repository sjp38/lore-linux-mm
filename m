Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 123DE2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 11:34:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k74so13499248qke.4
        for <linux-mm@kvack.org>; Wed, 10 May 2017 08:34:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si3419893qty.279.2017.05.10.08.34.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 08:34:42 -0700 (PDT)
Message-ID: <1494430466.29205.17.camel@redhat.com>
Subject: Re: [patch 3/3] MM: allow per-cpu vmstat_worker configuration
From: Rik van Riel <riel@redhat.com>
Date: Wed, 10 May 2017 11:34:26 -0400
In-Reply-To: <20170503184039.901336380@redhat.com>
References: <20170503184007.174707977@redhat.com>
	 <20170503184039.901336380@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>

On Wed, 2017-05-03 at 15:40 -0300, Marcelo Tosatti wrote:
> Following the reasoning on the last patch in the series,
> this patch allows configuration of the per-CPU vmstat worker:
> it allows the user to disable the per-CPU vmstat worker.
> 
> Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

Is there ever a case where you would want to configure
this separately from the vmstat_threshold parameter?

What use cases are you trying to address?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
