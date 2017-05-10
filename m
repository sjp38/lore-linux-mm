Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7C082808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 09:37:05 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t26so11163462qtg.12
        for <linux-mm@kvack.org>; Wed, 10 May 2017 06:37:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z1si3481203qkg.256.2017.05.10.06.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 06:37:04 -0700 (PDT)
Message-ID: <1494423419.29205.15.camel@redhat.com>
Subject: Re: [patch 1/3] MM: remove unused quiet_vmstat function
From: Rik van Riel <riel@redhat.com>
Date: Wed, 10 May 2017 09:36:59 -0400
In-Reply-To: <20170503184039.737799631@redhat.com>
References: <20170503184007.174707977@redhat.com>
	 <20170503184039.737799631@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>

On Wed, 2017-05-03 at 15:40 -0300, Marcelo Tosatti wrote:
> Remove unused quiet_vmstat function.
> 
> Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
