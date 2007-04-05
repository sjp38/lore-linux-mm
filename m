Message-ID: <461474FA.5080807@redhat.com>
Date: Thu, 05 Apr 2007 00:03:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: A question about page aging in page frame reclaimation
References: <ac8af0be0704040333k25459a8cwec6729e8ad6a4db4@mail.gmail.com>
In-Reply-To: <ac8af0be0704040333k25459a8cwec6729e8ad6a4db4@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zhao Forrest wrote:
> Hi Riel,
> 
> I'm studying the code of page frame reclaimation in 2.6 kernel. From
> my understanding, there should be kernel thread periodically scanning
                           ^^^^^^^^^

"should be"?  What makes you think that?

> But I can't find the related code.....

That's probably because it doesn't exist.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
