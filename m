Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 226AB6B004D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 05:39:59 -0400 (EDT)
Received: by gxk20 with SMTP id 20so8339812gxk.14
        for <linux-mm@kvack.org>; Tue, 26 May 2009 02:40:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090526083538.GA29563@elf.ucw.cz>
References: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
	 <20090526083538.GA29563@elf.ucw.cz>
Date: Tue, 26 May 2009 18:40:35 +0900
Message-ID: <44c63dc40905260240n2c4e348ai74b7d42954098bf1@mail.gmail.com>
Subject: Re: [PATCH][mmtom] clean up once printk routine
From: Minchan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dominik Brodowski <linux@dominikbrodowski.net>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Pavel.

On Tue, May 26, 2009 at 5:35 PM, Pavel Machek <pavel@ucw.cz> wrote:
> Hi!
>
>> Yes. There are also some places to be able to use printk_once().
>> Are there any place I missed ?
>>
>> =3D=3D CUT HERE =3D=3D
>>
>> There are some places to be able to use printk_once instead of hard codi=
ng.
>>
>> It will help code readability and maintenance.
>> This patch doesn't change function's behavior.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> CC: Dominik Brodowski <linux@dominikbrodowski.net>
>> CC: David S. Miller <davem@davemloft.net>
>> CC: Ingo Molnar <mingo@elte.hu>
>> ---
>> =C2=A0arch/x86/kernel/cpu/common.c =C2=A0| =C2=A0 =C2=A08 ++------
>> =C2=A0drivers/net/3c515.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =
=C2=A07 ++-----
>> =C2=A0drivers/pcmcia/pcmcia_ioctl.c | =C2=A0 =C2=A09 +++------
>> =C2=A03 files changed, 7 insertions(+), 17 deletions(-)
>>
>> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
>> index 82bec86..dc0f694 100644
>> --- a/arch/x86/kernel/cpu/common.c
>> +++ b/arch/x86/kernel/cpu/common.c
>> @@ -496,13 +496,9 @@ static void __cpuinit get_cpu_vendor(struct cpuinfo=
_x86 *c)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 if (!printed) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printed++;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR
>> + =C2=A0 =C2=A0 printk_once(KERN_ERR
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "CPU: ven=
dor_id '%s' unknown, using generic init.\n", v);
>> -
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR "CPU: Your s=
ystem may be unstable.\n");
>> - =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 printk_once(KERN_ERR "CPU: Your system may be unstable.\=
n");
>>
>
> You should delete the variable, right?

Yes. you're right.

> Plus, the code now uses two variables instead of one.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Pavel

Thanks for pointing me out.
I will repost the patch with your advise.


> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/b=
log.html
>



--=20
Thanks,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
