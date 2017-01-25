Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4BB56B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:40:19 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so38144800wme.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:40:19 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id f87si22439244wmh.24.2017.01.25.05.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 05:40:18 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id c85so42529411wmi.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:40:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170125130901.GP32377@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org> <20170112153717.28943-6-mhocko@kernel.org>
 <CAGXu5jKhYP=5YNuntzmG64WL92F59VKhByOh9nqaGP7-LBEnng@mail.gmail.com>
 <20170112173745.GC31509@dhcp22.suse.cz> <7c109e9e-e28b-3ddb-42b6-902f46bf0572@suse.cz>
 <20170124150004.GM6867@dhcp22.suse.cz> <a4b4e2f4-f730-4f1d-7f41-36ba0d34f1a6@suse.cz>
 <20170125130901.GP32377@dhcp22.suse.cz>
From: Ilya Dryomov <idryomov@gmail.com>
Date: Wed, 25 Jan 2017 14:40:17 +0100
Message-ID: <CAOi1vP8-8WWF7e=L34Hq7pcS+XhV0K3pBrBzkTsNeiO8caf4uw@mail.gmail.com>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded variants
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Network Development <netdev@vger.kernel.org>

On Wed, Jan 25, 2017 at 2:09 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 25-01-17 12:15:59, Vlastimil Babka wrote:
>> On 01/24/2017 04:00 PM, Michal Hocko wrote:
>> > > > Well, I am not opposed to kvmalloc_array but I would argue that this
>> > > > conversion cannot introduce new overflow issues. The code would have
>> > > > to be broken already because even though kmalloc_array checks for the
>> > > > overflow but vmalloc fallback doesn't...
>> > >
>> > > Yeah I agree, but if some of the places were really wrong, after the
>> > > conversion we won't see them anymore.
>> > >
>> > > > If there is a general interest for this API I can add it.
>> > >
>> > > I think it would be better, yes.
>> >
>> > OK, fair enough. I will fold the following into the original patch. I
>> > was little bit reluctant to create kvcalloc so I've made the original
>> > callers more talkative and added | __GFP_ZERO.
>>
>> Fair enough,
>>
>> > To be honest I do not
>> > really like how kcalloc...
>>
>> how kcalloc what?
>
> how kcalloc hides the GFP_ZERO and the name doesn't reflect that.

The userspace calloc() is specified to zero memory, so I'd say the name
does reflect that.

Thanks,

                Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
