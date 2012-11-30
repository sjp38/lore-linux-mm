Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <50B82A7C.8020202@cn.fujitsu.com>
Date: Fri, 30 Nov 2012 11:39:40 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com> <20121129153930.477e9709.akpm@linux-foundation.org> <20121130000443.GK18574@lenny.home.zabbo.net>
In-Reply-To: <20121130000443.GK18574@lenny.home.zabbo.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@zabbo.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Zach,

Thanks for your advice. So agree, I will look into it to lead aio=20
to use non-movable pages.


Thanks,
linfeng
On 11/30/2012 08:04 AM, Zach Brown wrote:
>> The best I can think of is to make changes in or around
>> get=5Fuser=5Fpages(), to steal the pages from userspace and replace them
>> with non-movable ones before pinning them.  The performance cost of
>> something like this would surely be unacceptable for direct-io, but
>> maybe OK for the aio ring and futexes.
>=20
> In the aio case it seems like it could be taught to populate the mapping
> with non-movable pages to begin with.  It's calling get=5Fuser=5Fpages() a
> few lines after instantiating the mapping itself with do=5Fmmap=5Fpgoff().
>=20
> - z
>=20

--=20
--------------------------------------------------
Lin Feng
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST) No. 6 Wenzhu Road,
Nanjing, 210012, China
PHONE=EF=BC=9A+86-25-86630566-8557=20
COINS=EF=BC=9A7998-8557=20
FAX=EF=BC=9A+86-25-83317685
MAIL=EF=BC=9Alinfeng@cn.fujitsu.com
--------------------------------------------------
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
