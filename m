Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5356B0315
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:35:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f185so69233962pgc.10
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 23:35:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 195si8418781pfb.354.2017.06.12.23.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 23:35:06 -0700 (PDT)
Date: Mon, 12 Jun 2017 23:34:46 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 05/11] Creation of "check_vmflags" LSM hook
Message-ID: <20170613063446.GA12537@infradead.org>
References: <1497286620-15027-1-git-send-email-s.mesoraca16@gmail.com>
 <1497286620-15027-6-git-send-email-s.mesoraca16@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497286620-15027-6-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org

On Mon, Jun 12, 2017 at 06:56:54PM +0200, Salvatore Mesoraca wrote:
> Creation of a new LSM hook to check if a given configuration of vmflags,
> for a new memory allocation request, should be allowed or not.
> It's placed in "do_mmap", "do_brk_flags" and "__install_special_mapping".

Please always post the whole series including the users, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
