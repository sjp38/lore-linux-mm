Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 2CC8C6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 21:20:40 -0400 (EDT)
Message-ID: <51DCB6DB.3070209@cn.fujitsu.com>
Date: Wed, 10 Jul 2013 09:20:27 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Support multiple pages allocation
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com> <20130703152824.GB30267@dhcp22.suse.cz> <51D44890.4080003@gmail.com> <51D44AE7.1090701@gmail.com> <20130704042450.GA7132@lge.com> <20130704100044.GB7833@dhcp22.suse.cz> <20130710003142.GA2152@lge.com>
In-Reply-To: <20130710003142.GA2152@lge.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

=E4=BA=8E 2013/7/10 8:31, Joonsoo Kim =E5=86=99=E9=81=93:
> On Thu, Jul 04, 2013 at 12:00:44PM +0200, Michal Hocko wrote:
>> On Thu 04-07-13 13:24:50, Joonsoo Kim wrote:
>>> On Thu, Jul 04, 2013 at 12:01:43AM +0800, Zhang Yanfei wrote:
>>>> On 07/03/2013 11:51 PM, Zhang Yanfei wrote:
>>>>> On 07/03/2013 11:28 PM, Michal Hocko wrote:
>>>>>> On Wed 03-07-13 17:34:15, Joonsoo Kim wrote:
>>>>>> [...]
>>>>>>> For one page allocation at once, this patchset makes allocator slow=
er than
>>>>>>> before (-5%).=20
>>>>>>
>>>>>> Slowing down the most used path is a no-go. Where does this slow down
>>>>>> come from?
>>>>>
>>>>> I guess, it might be: for one page allocation at once, comparing to t=
he original
>>>>> code, this patch adds two parameters nr=5Fpages and pages and will do=
 extra checks
>>>>> for the parameter nr=5Fpages in the allocation path.
>>>>>
>>>>
>>>> If so, adding a separate path for the multiple allocations seems bette=
r.
>>>
>>> Hello, all.
>>>
>>> I modify the code for optimizing one page allocation via likely macro.
>>> I attach a new one at the end of this mail.
>>>
>>> In this case, performance degradation for one page allocation at once i=
s -2.5%.
>>> I guess, remained overhead comes from two added parameters.
>>> Is it unreasonable cost to support this new feature?
>>
>> Which benchmark you are using for this testing?
>=20
> I use my own module which do allocation repeatedly.
>=20
>>
>>> I think that readahead path is one of the most used path, so this penal=
ty looks
>>> endurable. And after supporting this feature, we can find more use case=
s.
>>
>> What about page faults? I would oppose that page faults are =5Fmuch=5F m=
ore
>> frequent than read ahead so you really cannot slow them down.
>=20
> You mean page faults for anon?
> Yes. I also think that it is much more frequent than read ahead.
> Before futher discussion, I will try to add a separate path
> for the multiple allocations.

Some days ago, I was thinking that this multiple allocation behaviour
may be useful for vmalloc allocations. So I think it is worth trying.

>=20
> Thanks.
>=20
>>
>> [...]
>> --=20
>> Michal Hocko
>> SUSE Labs
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20


--=20
Thanks.
Zhang Yanfei
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
