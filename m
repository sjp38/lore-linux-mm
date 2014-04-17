Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 76DA26B008A
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 10:52:00 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h18so754670igc.2
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 07:52:00 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id g1si2922885igd.14.2014.04.17.07.51.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Apr 2014 07:51:59 -0700 (PDT)
Message-ID: <534FEA83.1010603@infradead.org>
Date: Thu, 17 Apr 2014 07:51:47 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: 0/N patch emails - to use or not to use?
References: <CALZtONCR-ewaZjmZ_CznwqtGvzkmdTC0hQbbm2YDaSBvWv8XqA@mail.gmail.com> <20140416155730.b2dc1a551307f736438a85d7@linux-foundation.org>
In-Reply-To: <20140416155730.b2dc1a551307f736438a85d7@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>

On 04/16/2014 03:57 PM, Andrew Morton wrote:
> On Sat, 12 Apr 2014 17:23:31 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
> 
>> Hi Andrew,
>>
>> I noticed in your The Perfect Patch doc:
>> http://www.ozlabs.org/~akpm/stuff/tpp.txt
>> Section 6b says you don't like 0/N patch series description-only
>> emails.  Is that still true?  Because it seems the majority of patch
>> series do include a 0/N descriptive email...
> 
> hm, I think what I said about git there isn't true - merge commits can
> contain changelogs.
> 
> Whatever.  0/n is OK and is more email-reader-friendly.

I don't mind a 0/n patch if there is lots of history or background
or data to be presented, but I find it silly to use a patch 0/1 and
patch 1/1 for a single, small patch, like some people do because that
is what git wants to do.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
