Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46DF46B0010
	for <linux-mm@kvack.org>; Mon,  7 May 2018 05:43:45 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f1-v6so20938821qtm.12
        for <linux-mm@kvack.org>; Mon, 07 May 2018 02:43:45 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g31-v6si5332980qtg.43.2018.05.07.02.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 02:43:44 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <20180502211254.GA5863@ram.oc3035372033.ibm.com>
 <CALCETrUfO=vXg5rT-n=y8pLktcq5+ORvgpsOXCHG4GaugB3k2A@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <c0288ca0-4f8f-9a38-550f-f6bbfb5a91cf@redhat.com>
Date: Mon, 7 May 2018 11:43:40 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrUfO=vXg5rT-n=y8pLktcq5+ORvgpsOXCHG4GaugB3k2A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, linuxram@us.ibm.com
Cc: Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>

On 05/02/2018 11:18 PM, Andy Lutomirski wrote:
> I don't know about POWER's ISA, but this is crappy behavior.  If a thread
> temporarily grants itself access to a restrictive memory key and then gets
> a signal, the signal handler should*not*  have access to that key.

Sorry, that totally depends on what the signal handler does, especially 
for synchronously delivered signals.

Thanks,
Florian
