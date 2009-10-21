Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DED056B005A
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 21:12:32 -0400 (EDT)
Message-ID: <COL115-W206803474483F1CDB34CF29FBF0@phx.gbl>
From: Bo Liu <bo-liu@hotmail.com>
Subject: RE: [PATCH] try_to_unuse : remove redundant swap_count()
Date: Wed, 21 Oct 2009 09:12:09 +0800
In-Reply-To: 
 <0f7b4023bee9b7ccc47998cd517d193c.squirrel@webmail-b.css.fujitsu.com>
References: <COL115-W535064AC2F576372C1BB1B9FC00@phx.gbl>
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


 <0f7b4023bee9b7ccc47998cd517d193c.squirrel@webmail-b.css.fujitsu.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0



>> While comparing with swcount=2Cit's no need to
>> call swap_count(). Just as int set_start_mm =3D
>> (*swap_map>=3D swcount) is ok.
>>
> Hmm ?
> *swap_map =3D (SWAP_HAS_CACHE) | count. What this change means ?
=20
Because swcount is assigned value *swap_map=2C not swap_count(*swap_map)=2C=
 so I
think here should compare with *swap_map not swap_count(*swap_map).
=20
And refer to variable set_start_mm=2C it is inited also by comparing *swap_=
map and=20
swcount=2C not swap_count(*swap_map) and swcount.
So=2C I submited this patch.

>
> Anyway=2C swap_count() macro is removed by Hugh's patch (queued in -mm)
=20
I am sorry for not notice that. So=2C just forget about this patch.
=20
Thanks!
-Bo=20

>
> Regards=2C
> -Kame
>
>> Signed-off-by: Bo Liu=20
>> ---
>>
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 63ce10f..2456fc6 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -1152=2C7 +1152=2C7 @@ static int try_to_unuse(unsigned int type)
>> retval =3D unuse_mm(mm=2C entry=2C page)=3B
>> if (set_start_mm &&
>> - swap_count(*swap_map) < swcount) {
>> + ((*swap_map) < swcount)) {
>> mmput(new_start_mm)=3B
>> atomic_inc(&mm->mm_users)=3B
>> new_start_mm =3D mm=3B
>>
>> --
>> 1.6.0.6 		 	   		 =20
_________________________________________________________________
Windows Live Hotmail: Your friends can get your Facebook updates=2C right f=
rom Hotmail=AE.
http://www.microsoft.com/middleeast/windows/windowslive/see-it-in-action/so=
cial-network-basics.aspx?ocid=3DPID23461::T:WLMTAGL:ON:WL:en-xm:SI_SB_4:092=
009=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
