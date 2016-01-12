Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3BE828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:11:03 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id 77so364675898ioc.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 12:11:03 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0136.hostedemail.com. [216.40.44.136])
        by mx.google.com with ESMTPS id w79si10903937iod.140.2016.01.12.12.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 12:11:02 -0800 (PST)
Date: Tue, 12 Jan 2016 15:10:52 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC V5] Add gup trace points support
Message-ID: <20160112151052.168bba85@gandalf.local.home>
In-Reply-To: <56955B76.2060503@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
	<56955B76.2060503@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Tue, 12 Jan 2016 12:00:54 -0800
"Shi, Yang" <yang.shi@linaro.org> wrote:

> Hi Steven,
> 
> Any more comments on this series? How should I proceed it?
> 

The tracing part looks fine to me. Now you just need to get the arch
maintainers to ack each of the arch patches, and I can pull them in for
4.6. Too late for 4.5. Probably need Andrew Morton's ack for the
mm/gup.c patch.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
