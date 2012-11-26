Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8AAD76B005A
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 20:49:52 -0500 (EST)
Message-ID: <50B2C38A.7010201@cn.fujitsu.com>
Date: Mon, 26 Nov 2012 09:19:06 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/5] x86: get pg_data_t's memory from other node
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-2-git-send-email-tangchen@cn.fujitsu.com> <50B020A4.9060801@huawei.com>
In-Reply-To: <50B020A4.9060801@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 11/24/2012 09:19 AM, Jiang Liu wrote:
> On 2012-11-23 18:44, Tang Chen wrote:
>> From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>> @@ -224,9 +224,14 @@ static void =5F=5Finit setup=5Fnode=5Fdata(int nid,=
 u64 start, u64 end)
>>   	} else {
>>   		nd=5Fpa =3D memblock=5Falloc=5Fnid(nd=5Fsize, SMP=5FCACHE=5FBYTES, n=
id);
>>   		if (!nd=5Fpa) {
>> -			pr=5Ferr("Cannot find %zu bytes in node %d\n",
>> -			       nd=5Fsize, nid);
>> -			return;
>> +			pr=5Fwarn("Cannot find %zu bytes in node %d\n",
>> +				nd=5Fsize, nid);
> Hi Tang=EF=BC=8C
> 	Should this be an "pr=5Finfo" because the allocation failure is expected?

Hi Liu,

Sure, followed. Thanks. :)

> Regards!
> Gerry
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
