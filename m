Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C19678E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 16:35:12 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id y1so1570183wrd.7
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 13:35:12 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u141si37136063wmu.75.2019.01.23.13.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 23 Jan 2019 13:35:11 -0800 (PST)
Date: Wed, 23 Jan 2019 22:35:06 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
Message-ID: <20190123213506.nfjqpbhbctmls2lf@linutronix.de>
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190122152151.16139-8-gregkh@linuxfoundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On 2019-01-22 16:21:07 [+0100], Greg Kroah-Hartman wrote:
> When calling debugfs functions, there is no need to ever check the
> return value.  The function can work or not, but the code logic should
> never do something different based on this.
> 
> And as the return value does not matter at all, no need to save the
> dentry in struct backing_dev_info, so delete it.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Anders Roxell <anders.roxell@linaro.org>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

with "[PATCH 2/2] debugfs: return error values, not NULL"
Reviewed-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Sebastian
