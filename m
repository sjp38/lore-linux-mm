Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f79.google.com (mail-oa0-f79.google.com [209.85.219.79])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8506B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:58:45 -0500 (EST)
Received: by mail-oa0-f79.google.com with SMTP id m1so148701oag.6
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 08:58:44 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id p3si16555448pbj.38.2014.01.13.11.34.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jan 2014 11:34:54 -0800 (PST)
Received: from compute2.internal (compute2.nyi.mail.srv.osa [10.202.2.42])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 4724C211E0
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 14:34:53 -0500 (EST)
Message-ID: <52D43FDB.9090003@iki.fi>
Date: Mon, 13 Jan 2014 21:34:51 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: use lockdep_assert_held
References: <20140110122349.GN31570@twins.programming.kicks-ass.net>
In-Reply-To: <20140110122349.GN31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, penberg@kernel.org
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com

On 01/10/2014 02:23 PM, Peter Zijlstra wrote:
> Instead of using comments in an attempt at getting the locking right,
> use proper assertions that actively warn you if you got it wrong.
>
> Also add extra braces in a few sites to comply with coding-style.
>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
