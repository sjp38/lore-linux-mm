Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4A16B02A5
	for <linux-mm@kvack.org>; Tue,  8 May 2018 11:39:40 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id r7-v6so12158304ith.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 08:39:40 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s69-v6si9826256ita.40.2018.05.08.08.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 08:39:38 -0700 (PDT)
Subject: Re: [PATCH] mm: expland documentation over __read_mostly
References: <e2aa9491-c1e3-4ae1-1ab2-589a6642a24a@infradead.org>
 <20180507231506.4891-1-mcgrof@kernel.org>
 <32208.1525768094@warthog.procyon.org.uk>
 <20180508112321.GA30120@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7d6664dc-01f5-55d9-d309-0378ff609b8a@infradead.org>
Date: Tue, 8 May 2018 08:39:30 -0700
MIME-Version: 1.0
In-Reply-To: <20180508112321.GA30120@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, David Howells <dhowells@redhat.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, tglx@linutronix.de, arnd@arndb.de, cl@linux.com, keescook@chromium.org, luto@amacapital.net, longman@redhat.com, viro@zeniv.linux.org.uk, ebiederm@xmission.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/08/2018 04:23 AM, Matthew Wilcox wrote:
> On Tue, May 08, 2018 at 09:28:14AM +0100, David Howells wrote:
>> Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>>>> + * execute a critial path. We should be mindful and selective if its use.
>>>
>>>                                                                  of its use.
>>
>>                                                                    in its use.
> 								     with its use.
> 
> Nah, just kidding.  Let's go with "in".
> 

Yeah, no, I don't care.  Just flip a 3-sided coin.

-- 
~Randy
