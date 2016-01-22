Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 52A616B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 02:48:46 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id r129so202090884wmr.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 23:48:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t187si2935383wmg.54.2016.01.21.23.48.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 23:48:45 -0800 (PST)
Date: Fri, 22 Jan 2016 08:48:56 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] Persistent Memory Error Handling
Message-ID: <20160122074856.GA17265@quack.suse.cz>
References: <x49oacee71h.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49oacee71h.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Hi,

On Thu 21-01-16 20:28:58, Jeff Moyer wrote:
> The SNIA Non-volatile Memory Programming Technical Work Group (NVMP-TWG)
> is working on more closely defining how errors are reported and
> cleared for persistent memory.  I'd like to give an overview of that
> work and open the floor to discussion.  This topic covers file systems,
> memory management, and the block layer so would be suitable for a
> plenary session.

Yeah, this sounds like a good topic for a plenary session to me.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
