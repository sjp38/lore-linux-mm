Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6986B0172
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 12:36:48 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so925758pab.40
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 09:36:47 -0800 (PST)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id hi3si3372446pbb.183.2013.11.07.09.36.46
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 09:36:46 -0800 (PST)
Received: by mail-ie0-f182.google.com with SMTP id as1so1367822iec.27
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 09:36:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA25o9TaWG7Wu6uXwyapKD1oaVYqb47_9Ag7JbT-ZyQT7iaJEA@mail.gmail.com>
References: <20131107070451.GA10645@bbox>
	<CAA25o9TaWG7Wu6uXwyapKD1oaVYqb47_9Ag7JbT-ZyQT7iaJEA@mail.gmail.com>
Date: Thu, 7 Nov 2013 09:36:44 -0800
Message-ID: <CAA25o9R1EppGKMBojtWk0UHEqD3aYsNxqF+P7xfVEy1i8ameSQ@mail.gmail.com>
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Nov 7, 2013 at 9:06 AM, Luigi Semenzato <semenzato@google.com> wrote:

-> Android 4.4 KitKat is also using zram, to better support devices with
-> less than 1 MB RAM.  (That's the news.)

Sorry, I meant 1 GB RAM.

http://dilbert.com/strips/comic/1991-09-27/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
