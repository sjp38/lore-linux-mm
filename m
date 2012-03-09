Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 454806B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 22:24:26 -0500 (EST)
Received: by pbcup15 with SMTP id up15so2456715pbc.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 19:24:25 -0800 (PST)
Message-ID: <4F5977E6.5040205@gmail.com>
Date: Fri, 09 Mar 2012 11:24:22 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: Free spare array to avoid memory leak
References: <1331036004-7550-1-git-send-email-handai.szj@taobao.com>	<20120307230819.GA10238@shutemov.name>	<4F581554.6020801@gmail.com>	<20120308103510.GA12897@shutemov.name>	<4F588DF5.60300@gmail.com> <20120309102431.5a8a1c3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120309102431.5a8a1c3d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, cgroups@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 03/09/2012 09:24 AM, KAMEZAWA Hiroyuki wrote:
> On Thu, 08 Mar 2012 18:46:13 +0800
> Sha Zhengju<handai.szj@gmail.com>  wrote:
>
>> On 03/08/2012 06:35 PM, Kirill A. Shutemov wrote:
>>> On Thu, Mar 08, 2012 at 10:11:32AM +0800, Sha Zhengju wrote:
>>>> On 03/08/2012 07:08 AM, Kirill A. Shutemov wrote:
>>>>> On Tue, Mar 06, 2012 at 08:13:24PM +0800, Sha Zhengju wrote:
>>>>>> From: Sha Zhengju<handai.szj@taobao.com>
>>>>>>
>>>>>> When the last event is unregistered, there is no need to keep the spare
>>>>>> array anymore. So free it to avoid memory leak.
>>>>> It's not a leak. It will be freed on next event register.
>>>> Yeah, I noticed that. But what if it is just the last one and no more
>>>> event registering ?
>>> See my question below. ;)
>>>
>>>>> Yeah, we don't have to keep spare if primary is empty. But is it worth to
>>>>> make code more complicated to save few bytes of memory?
>>>>>
>> If we unregister the last event and *don't* register a new event anymore,
>> the primary is freed but the spare is still kept which has no chance to
>> free.
>>
>> IMHO, it's obvious not a problem of saving bytes but *memory leak*.
>>
> IMHO, it's cached. It will be freed when a memcg is destroyed.

I didn't see that behavior.  Could you point it out ? :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
