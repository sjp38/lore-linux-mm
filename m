Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 659316B005A
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 22:22:00 -0500 (EST)
Message-ID: <50DA6D1E.1010209@cn.fujitsu.com>
Date: Wed, 26 Dec 2012 11:21:02 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 06/14] memory-hotplug: implement register_page_bootmem_info_section
 of sparse-vmemmap
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-7-git-send-email-tangchen@cn.fujitsu.com> <50D95F51.9090007@huawei.com>
In-Reply-To: <50D95F51.9090007@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 12/25/2012 04:09 PM, Jianguo Wu wrote:
>> +
>> +		if (!cpu=5Fhas=5Fpse) {
>> +			next =3D (addr + PAGE=5FSIZE)&  PAGE=5FMASK;
>> +			pmd =3D pmd=5Foffset(pud, addr);
>> +			if (pmd=5Fnone(*pmd))
>> +				continue;
>> +			get=5Fpage=5Fbootmem(section=5Fnr, pmd=5Fpage(*pmd),
>> +					 MIX=5FSECTION=5FINFO);
>> +
>> +			pte =3D pte=5Foffset=5Fkernel(pmd, addr);
>> +			if (pte=5Fnone(*pte))
>> +				continue;
>> +			get=5Fpage=5Fbootmem(section=5Fnr, pte=5Fpage(*pte),
>> +					 SECTION=5FINFO);
>> +		} else {
>> +			next =3D pmd=5Faddr=5Fend(addr, end);
>> +
>> +			pmd =3D pmd=5Foffset(pud, addr);
>> +			if (pmd=5Fnone(*pmd))
>> +				continue;
>> +			get=5Fpage=5Fbootmem(section=5Fnr, pmd=5Fpage(*pmd),
>> +					 SECTION=5FINFO);
>
> Hi Tang=EF=BC=8C
> 	In this case, pmd maps 512 pages, but you only get=5Fpage=5Fbootmem() on=
 the first page.
> I think the whole 512 pages should be get=5Fpage=5Fbootmem(), what do you=
 think?
>
Hi Wu,

Yes, thanks. I will fix it. :)

Thanks. :)

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
