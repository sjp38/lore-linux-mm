Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C49D06B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 13:12:52 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id o22so6314835itc.9
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 10:12:52 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id o23si11738010iob.43.2018.03.08.10.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 10:12:52 -0800 (PST)
Date: Thu, 8 Mar 2018 12:12:50 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slub: use jitter-free reference while printing age
In-Reply-To: <1520492010-19389-1-git-send-email-cpandya@codeaurora.org>
Message-ID: <alpine.DEB.2.20.1803081211230.14668@nuc-kabylake>
References: <1520492010-19389-1-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Mar 2018, Chintan Pandya wrote:

> In this case, object got freed later but 'age'
> shows otherwise. This could be because, while
> printing this info, we print allocation traces
> first and free traces thereafter. In between,
> if we get schedule out or jiffies increment,
> (jiffies - t->when) could become meaningless.

Could you show the new output style too?

Acked-by: Christoph Lameter <cl@linux.com>
