Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C06A6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 17:50:03 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id di3so11102738pab.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 14:50:03 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id wb8si7582975pab.119.2016.05.26.14.50.00
        for <linux-mm@kvack.org>;
        Thu, 26 May 2016 14:50:01 -0700 (PDT)
Date: Fri, 27 May 2016 06:50:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6r2 11/12] zsmalloc: page migration support
Message-ID: <20160526215022.GA2322@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
In-Reply-To: <1463754225-31311-12-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Follow up Sergey's review
