Received: by ug-out-1314.google.com with SMTP id s2so612030uge
        for <linux-mm@kvack.org>; Wed, 04 Apr 2007 03:33:39 -0700 (PDT)
Message-ID: <ac8af0be0704040333k25459a8cwec6729e8ad6a4db4@mail.gmail.com>
Date: Wed, 4 Apr 2007 18:33:39 +0800
From: "Zhao Forrest" <forrest.zhao@gmail.com>
Subject: A question about page aging in page frame reclaimation
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Riel,

I'm studying the code of page frame reclaimation in 2.6 kernel. From
my understanding, there should be kernel thread periodically scanning
the active and inactive list and move the page frames between active
and inactive list according to LRU rule.

But I can't find the related code.....would you please point me to the
code piece that implement this "page aging" functionality?
Sorry for the stupid question, but I think I don't have a very strong
code-reading ability.

Thanks in advance,
Forrest

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
