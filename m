Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id B9CD66B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 16:42:37 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so2217769iec.19
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 13:42:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id q6si2863952igr.54.2014.06.25.13.42.36
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 13:42:37 -0700 (PDT)
Date: Wed, 25 Jun 2014 13:42:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-Id: <20140625134235.4f32768faa1a4380a62458ff@linux-foundation.org>
In-Reply-To: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org

On Wed, 25 Jun 2014 16:40:18 +0100 Steve Capper <steve.capper@linaro.org> wrote:

> This series implements general forms of get_user_pages_fast and
> __get_user_pages_fast and activates them for arm and arm64.

Why not x86?

I think I might have already asked this.  If so, it's your fault for
not updating the changelog ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
