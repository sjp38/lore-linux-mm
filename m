Message-ID: <479783D7.9070802@qumranet.com>
Date: Wed, 23 Jan 2008 20:13:43 +0200
From: Izik Eidus <izike@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC][PATCH 2/5] add new exported function replace_page()
References: <4794C40A.3020500@qumranet.com> <20080123130426.45dad2db@bree.surriel.com>
In-Reply-To: <20080123130426.45dad2db@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Mon, 21 Jan 2008 18:10:50 +0200
> Izik Eidus <izike@qumranet.com> wrote:
>
>   
>
> What prevents another CPU from freeing newpage while we run through
> the start of replace_page() ?
>
>   
before calling to replace_page one have to call to get_page() and to do 
put_page() after it finished
this what i am doing in ksm.c

should i do it in diffrent way?

-- 
woof.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
