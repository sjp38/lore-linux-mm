Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87E538E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:24:33 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so9419340pff.5
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:24:33 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j12si24612906pgq.26.2019.01.10.20.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 20:24:32 -0800 (PST)
Subject: Re: [PATCH 1/3] coredump: Replace opencoded set_mask_bits()
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
 <1547166387-19785-2-git-send-email-vgupta@synopsys.com>
From: Anthony Yznaga <anthony.yznaga@oracle.com>
Message-ID: <c513c1df-00f3-8c41-3d42-524992b011b1@oracle.com>
Date: Thu, 10 Jan 2019 20:24:12 -0800
MIME-Version: 1.0
In-Reply-To: <1547166387-19785-2-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>, linux-kernel@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org



On 1/10/19 4:26 PM, Vineet Gupta wrote:
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Link: http://lkml.kernel.org/g/20150807115710.GA16897@redhat.com
> Acked-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>

Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
