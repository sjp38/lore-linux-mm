Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3E9B8E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 02:07:53 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n95so14789229qte.16
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 23:07:53 -0800 (PST)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id l45si2564093qtc.21.2019.01.18.23.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 23:07:52 -0800 (PST)
Subject: Re: [PATCH] mm: fix some typo scatter in mm directory
References: <20190118235123.27843-1-richard.weiyang@gmail.com>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <5f731d5b-841d-23c3-f077-9c66188de24b@iki.fi>
Date: Sat, 19 Jan 2019 09:07:46 +0200
MIME-Version: 1.0
In-Reply-To: <20190118235123.27843-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, cl@linux.com, penberg@kernel.org, rientjes@google.com



On 19/01/2019 1.51, Wei Yang wrote:
> No functional change.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>
