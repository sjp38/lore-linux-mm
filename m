Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B98AF5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 17:16:48 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D21EB82C2FC
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 17:26:02 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hC-aKuNsR29Z for <linux-mm@kvack.org>;
	Tue,  7 Apr 2009 17:25:56 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B14C882C30F
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 17:25:50 -0400 (EDT)
Date: Tue, 7 Apr 2009 17:11:26 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [5/16] POISON: Add support for poison swap entries
In-Reply-To: <20090407151002.0AA8F1D046E@basil.firstfloor.org>
Message-ID: <alpine.DEB.1.10.0904071710500.12192@qirst.com>
References: <20090407509.382219156@firstfloor.org> <20090407151002.0AA8F1D046E@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Could you separate the semantic changes to flag checking for migration
out for easier review?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
