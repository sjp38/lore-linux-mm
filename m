Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDAB38E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 01:50:28 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id b203so10250950vsd.20
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:50:28 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id y143si3753025vsc.58.2018.12.18.22.50.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Dec 2018 22:50:26 -0800 (PST)
Message-ID: <28b06130f6bfe38a1f82cff646a9e88ab318a841.camel@kernel.crashing.org>
Subject: Re: [PATCH V4 0/5] NestMMU pte upgrade workaround for mprotect
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 19 Dec 2018 09:30:32 +1100
In-Reply-To: <20181218171703.GA22729@infradead.org>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
	 <20181218171703.GA22729@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: npiggin@gmail.com, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, 2018-12-18 at 09:17 -0800, Christoph Hellwig wrote:
> This series seems to miss patches 1 and 2.

Odd, I got them...

Ben.
