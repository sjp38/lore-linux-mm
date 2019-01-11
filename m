Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 006ED8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:24:52 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b24so7513417pls.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:24:51 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d36si53427765pla.216.2019.01.10.20.24.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 20:24:50 -0800 (PST)
Subject: Re: [PATCH 2/3] fs: inode_set_flags() replace opencoded
 set_mask_bits()
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
 <1547166387-19785-3-git-send-email-vgupta@synopsys.com>
From: Anthony Yznaga <anthony.yznaga@oracle.com>
Message-ID: <5c9bf6bd-e29b-c985-b686-35f6dc272152@oracle.com>
Date: Thu, 10 Jan 2019 20:24:43 -0800
MIME-Version: 1.0
In-Reply-To: <1547166387-19785-3-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>, linux-kernel@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org



On 1/10/19 4:26 PM, Vineet Gupta wrote:
> It seems that 5f16f3225b0624 and 00a1a053ebe5, both with same commitlog
> ("ext4: atomically set inode->i_flags in ext4_set_inode_flags()")
> introduced the set_mask_bits API, but somehow missed not using it in
> ext4 in the end
>
> Also, set_mask_bits is used in fs quite a bit and we can possibly come up
> with a generic llsc based implementation (w/o the cmpxchg loop)
>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Theodore Ts'o <tytso@mit.edu>
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>

Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
