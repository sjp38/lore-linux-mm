Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 464D96B02CA
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 18:03:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r83so6726637pfj.5
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:03:25 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b5si1964995pli.190.2017.09.20.15.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 15:03:24 -0700 (PDT)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: RFC: replace jhash2 with xxhash
References: <CAGqmi75hqVN7YKopWFUdB1=PKMwrvTRTWVJCtfnWHJCz3Zj09w@mail.gmail.com>
Date: Wed, 20 Sep 2017 15:03:22 -0700
In-Reply-To: <CAGqmi75hqVN7YKopWFUdB1=PKMwrvTRTWVJCtfnWHJCz3Zj09w@mail.gmail.com>
	(Timofey Titovets's message of "Fri, 15 Sep 2017 14:46:19 +0300")
Message-ID: <87zi9p58ph.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org

Timofey Titovets <nefelim4ag@gmail.com> writes:
>
> P.S.
> I can write a patch if you found that useful

Seems useful. Please submit a patch.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
