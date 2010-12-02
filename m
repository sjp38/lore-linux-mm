Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B1CBD8D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 21:15:43 -0500 (EST)
Message-ID: <30d0b3f7-b955-4a83-b7e1-b73774bcae4e@blur>
From: "Westerdale, John" <John.Westerdale@stryker.com>
Date: Wed, 1 Dec 2010 21:15:49 -0500
MIME-Version: 1.0
Subject: Re: Difference between CommitLimit and Comitted_AS?
References: <B13AEDEE265EDB4182EA8B932E33033D13A904B7@SOSEXCHCL02.howost.strykercorp.com> <20101202103408.1584.A69D9226@jp.fujitsu.com>
In-Reply-To: <20101202103408.1584.A69D9226@jp.fujitsu.com>
Content-Type: multipart/alternative;
	boundary="Motorola-A-Mail-xe4FP56MXVvLz-1Y";
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Motorola-A-Mail-xe4FP56MXVvLz-1Y
Content-Type: text/plain; Format="Flowed"; DelSp="Yes"; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Kosaki,

Thanks very much for your information.

this server is running 25 pct of the projected 

Sent via DROID on Verizon Wireless

-----Original message-----
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
To: "Westerdale, John" <John.Westerdale@stryker.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
Sent: Thu, Dec 2, 2010 01:41:03 GMT+00:00
Subject: Re: Difference between CommitLimit and Comitted_AS?

> Hi All,
> 
> Am interested in differentiating the meaning of Commit* and Vmalloc*.
> 
> I had thought that the Committed_AS was the sum of memory allocations,
> and Commit_Limit was the available memory to serve this from.
> 
> That said, I winced when I saw that Committed_AS was almost twice the
> Commit__Limit.

Commit_Limit is only meaningful when overcommit_memory=2.

And, Linux has virtual memory feature. then memory allocation has 2 levels,
virtual address space allocation and physical memory allocation.
Committed_AS mean amount of committed virtual address space. It's not
physical.

Example, if you create thread, libc allocate lots address space for stack.
but typical program don't use so large stack. then physical memory will be 
not allocated.


> 
> Vmalloc looks inconsequential, but, the Commit* numbers must be there
> for a reason.
> 
> Is it safe to continue running with such a perceived over-commit?

Probably safe. Java runtime usually makes a lot of overcommits. but I have
no way to know exactly your system state. 


> 
> Is this evidence of a leak or garbage collection issues?

Maybe no.

> 
> This system functions as an App/Web front end using  Tomcat servelet
> engine, FWIW.
> 
> Thanks
> 
> John Westerdale
> 
> 
> MemTotal:     16634464 kB
> MemFree:      11077520 kB
> Buffers:        420768 kB
> Cached:        4379000 kB
> SwapCached:          0 kB
> Active:        4577960 kB
> Inactive:       685344 kB
> HighTotal:    15859440 kB
> HighFree:     10987632 kB
> LowTotal:       775024 kB
> LowFree:         89888 kB
> SwapTotal:     4194296 kB
> SwapFree:      4194296 kB
> Dirty:              12 kB
> Writeback:           0 kB
> AnonPages:      462748 kB
> Mapped:          65420 kB
> Slab:           260144 kB
> PageTables:      21712 kB
> NFS_Unstable:        0 kB
> Bounce:              0 kB
> CommitLimit:  12511528 kB
> Committed_AS: 22423356 kB
> VmallocTotal:   116728 kB
> VmallocUsed:      6600 kB
> VmallocChunk:   109612 kB
> HugePages_Total:     0
> HugePages_Free:      0
> HugePages_Rsvd:      0
> Hugepagesize:     2048 kB	
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>





--Motorola-A-Mail-xe4FP56MXVvLz-1Y
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PGh0bWw+PGhlYWQ+PHN0eWxlIHR5cGU9InRleHQvY3NzIj5ib2R5IHt3b3JkLXdyYXA6IGJyZWFr
LXdvcmQ7IGJhY2tncm91bmQtY29sb3I6I2ZmZmZmZjt9PC9zdHlsZT48L2hlYWQ+PGJvZHk+PGRp
diBzdHlsZT0iZm9udC1mYW1pbHk6IHNhbnMtc2VyaWY7IGZvbnQtc2l6ZTogMTZweCI+S29zYWtp
LDxicj48YnI+VGhhbmtzIHZlcnkgbXVjaCBmb3IgeW91ciBpbmZvcm1hdGlvbi48YnI+PGJyPnRo
aXMgc2VydmVyIGlzIHJ1bm5pbmcgMjUgcGN0IG9mIHRoZSBwcm9qZWN0ZWQgPGJyPjxicj48Zm9u
dCBjb2xvcj0iIzMzMzMzMyI+PGk+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZTogMTRweCI+PGZvbnQg
ZmFjZT0ic2Fucy1zZXJpZiI+U2VudCB2aWEgRFJPSUQgb24gVmVyaXpvbiBXaXJlbGVzczwvZm9u
dD48L3NwYW4+PC9pPjwvZm9udD48L2Rpdj48YnI+PGJyPi0tLS0tT3JpZ2luYWwgbWVzc2FnZS0t
LS0tPGJyPjxibG9ja3F1b3RlIHN0eWxlPSI7IGJvcmRlci1sZWZ0OiAycHggc29saWQgcmdiKDE2
LCAxNiwgMjU1KTsgbWFyZ2luLWxlZnQ6IDVweDsgcGFkZGluZy1sZWZ0OiA1cHg7Ij48ZGl2IHN0
eWxlPSJmb250LWZhbWlseTogc2Fucy1zZXJpZjsgZm9udC1zaXplOiAxNHB4Ij48Yj5Gcm9tOiA8
L2I+S09TQUtJIE1vdG9oaXJvICZsdDtrb3Nha2kubW90b2hpcm9AanAuZnVqaXRzdS5jb20mZ3Q7
PGI+PGJyPlRvOiA8L2I+JnF1b3Q7V2VzdGVyZGFsZSwgSm9obiZxdW90OyAmbHQ7Sm9obi5XZXN0
ZXJkYWxlQHN0cnlrZXIuY29tJmd0OzxiPjxicj5DYzogPC9iPmtvc2FraS5tb3RvaGlyb0BqcC5m
dWppdHN1LmNvbSwgbGludXgtbW1Aa3ZhY2sub3JnPGI+PGJyPlNlbnQ6IDwvYj5UaHUsIERlYyAy
LCAyMDEwIDAxOjQxOjAzIEdNVCswMDowMDxiPjxicj5TdWJqZWN0OiA8L2I+UmU6IERpZmZlcmVu
Y2UgYmV0d2VlbiBDb21taXRMaW1pdCBhbmQgQ29taXR0ZWRfQVM/PGJyPjxicj48L2Rpdj4+IEhp
IEFsbCw8YnI+PiA8YnI+PiBBbSBpbnRlcmVzdGVkIGluIGRpZmZlcmVudGlhdGluZyB0aGUgbWVh
bmluZyBvZiBDb21taXQqIGFuZCBWbWFsbG9jKi48YnI+PiA8YnI+PiBJIGhhZCB0aG91Z2h0IHRo
YXQgdGhlIENvbW1pdHRlZF9BUyB3YXMgdGhlIHN1bSBvZiBtZW1vcnkgYWxsb2NhdGlvbnMsPGJy
Pj4gYW5kIENvbW1pdF9MaW1pdCB3YXMgdGhlIGF2YWlsYWJsZSBtZW1vcnkgdG8gc2VydmUgdGhp
cyBmcm9tLjxicj4+IDxicj4+IFRoYXQgc2FpZCwgSSB3aW5jZWQgd2hlbiBJIHNhdyB0aGF0IENv
bW1pdHRlZF9BUyB3YXMgYWxtb3N0IHR3aWNlIHRoZTxicj4+IENvbW1pdF9fTGltaXQuPGJyPjxi
cj5Db21taXRfTGltaXQgaXMgb25seSBtZWFuaW5nZnVsIHdoZW4gb3ZlcmNvbW1pdF9tZW1vcnk9
Mi48YnI+PGJyPkFuZCwgTGludXggaGFzIHZpcnR1YWwgbWVtb3J5IGZlYXR1cmUuIHRoZW4gbWVt
b3J5IGFsbG9jYXRpb24gaGFzIDIgbGV2ZWxzLDxicj52aXJ0dWFsIGFkZHJlc3Mgc3BhY2UgYWxs
b2NhdGlvbiBhbmQgcGh5c2ljYWwgbWVtb3J5IGFsbG9jYXRpb24uPGJyPkNvbW1pdHRlZF9BUyBt
ZWFuIGFtb3VudCBvZiBjb21taXR0ZWQgdmlydHVhbCBhZGRyZXNzIHNwYWNlLiBJdCdzIG5vdDxi
cj5waHlzaWNhbC48YnI+PGJyPkV4YW1wbGUsIGlmIHlvdSBjcmVhdGUgdGhyZWFkLCBsaWJjIGFs
bG9jYXRlIGxvdHMgYWRkcmVzcyBzcGFjZSBmb3Igc3RhY2suPGJyPmJ1dCB0eXBpY2FsIHByb2dy
YW0gZG9uJ3QgdXNlIHNvIGxhcmdlIHN0YWNrLiB0aGVuIHBoeXNpY2FsIG1lbW9yeSB3aWxsIGJl
IDxicj5ub3QgYWxsb2NhdGVkLjxicj48YnI+PGJyPj4gPGJyPj4gVm1hbGxvYyBsb29rcyBpbmNv
bnNlcXVlbnRpYWwsIGJ1dCwgdGhlIENvbW1pdCogbnVtYmVycyBtdXN0IGJlIHRoZXJlPGJyPj4g
Zm9yIGEgcmVhc29uLjxicj4+IDxicj4+IElzIGl0IHNhZmUgdG8gY29udGludWUgcnVubmluZyB3
aXRoIHN1Y2ggYSBwZXJjZWl2ZWQgb3Zlci1jb21taXQ/PGJyPjxicj5Qcm9iYWJseSBzYWZlLiBK
YXZhIHJ1bnRpbWUgdXN1YWxseSBtYWtlcyBhIGxvdCBvZiBvdmVyY29tbWl0cy4gYnV0IEkgaGF2
ZTxicj5ubyB3YXkgdG8ga25vdyBleGFjdGx5IHlvdXIgc3lzdGVtIHN0YXRlLiA8YnI+PGJyPjxi
cj4+IDxicj4+IElzIHRoaXMgZXZpZGVuY2Ugb2YgYSBsZWFrIG9yIGdhcmJhZ2UgY29sbGVjdGlv
biBpc3N1ZXM/PGJyPjxicj5NYXliZSBuby48YnI+PGJyPj4gPGJyPj4gVGhpcyBzeXN0ZW0gZnVu
Y3Rpb25zIGFzIGFuIEFwcC9XZWIgZnJvbnQgZW5kIHVzaW5nICBUb21jYXQgc2VydmVsZXQ8YnI+
PiBlbmdpbmUsIEZXSVcuPGJyPj4gPGJyPj4gVGhhbmtzPGJyPj4gPGJyPj4gSm9obiBXZXN0ZXJk
YWxlPGJyPj4gPGJyPj4gPGJyPj4gTWVtVG90YWw6ICAgICAxNjYzNDQ2NCBrQjxicj4+IE1lbUZy
ZWU6ICAgICAgMTEwNzc1MjAga0I8YnI+PiBCdWZmZXJzOiAgICAgICAgNDIwNzY4IGtCPGJyPj4g
Q2FjaGVkOiAgICAgICAgNDM3OTAwMCBrQjxicj4+IFN3YXBDYWNoZWQ6ICAgICAgICAgIDAga0I8
YnI+PiBBY3RpdmU6ICAgICAgICA0NTc3OTYwIGtCPGJyPj4gSW5hY3RpdmU6ICAgICAgIDY4NTM0
NCBrQjxicj4+IEhpZ2hUb3RhbDogICAgMTU4NTk0NDAga0I8YnI+PiBIaWdoRnJlZTogICAgIDEw
OTg3NjMyIGtCPGJyPj4gTG93VG90YWw6ICAgICAgIDc3NTAyNCBrQjxicj4+IExvd0ZyZWU6ICAg
ICAgICAgODk4ODgga0I8YnI+PiBTd2FwVG90YWw6ICAgICA0MTk0Mjk2IGtCPGJyPj4gU3dhcEZy
ZWU6ICAgICAgNDE5NDI5NiBrQjxicj4+IERpcnR5OiAgICAgICAgICAgICAgMTIga0I8YnI+PiBX
cml0ZWJhY2s6ICAgICAgICAgICAwIGtCPGJyPj4gQW5vblBhZ2VzOiAgICAgIDQ2Mjc0OCBrQjxi
cj4+IE1hcHBlZDogICAgICAgICAgNjU0MjAga0I8YnI+PiBTbGFiOiAgICAgICAgICAgMjYwMTQ0
IGtCPGJyPj4gUGFnZVRhYmxlczogICAgICAyMTcxMiBrQjxicj4+IE5GU19VbnN0YWJsZTogICAg
ICAgIDAga0I8YnI+PiBCb3VuY2U6ICAgICAgICAgICAgICAwIGtCPGJyPj4gQ29tbWl0TGltaXQ6
ICAxMjUxMTUyOCBrQjxicj4+IENvbW1pdHRlZF9BUzogMjI0MjMzNTYga0I8YnI+PiBWbWFsbG9j
VG90YWw6ICAgMTE2NzI4IGtCPGJyPj4gVm1hbGxvY1VzZWQ6ICAgICAgNjYwMCBrQjxicj4+IFZt
YWxsb2NDaHVuazogICAxMDk2MTIga0I8YnI+PiBIdWdlUGFnZXNfVG90YWw6ICAgICAwPGJyPj4g
SHVnZVBhZ2VzX0ZyZWU6ICAgICAgMDxicj4+IEh1Z2VQYWdlc19Sc3ZkOiAgICAgIDA8YnI+PiBI
dWdlcGFnZXNpemU6ICAgICAyMDQ4IGtCCTxicj4+IDxicj4+IC0tPGJyPj4gVG8gdW5zdWJzY3Jp
YmUsIHNlbmQgYSBtZXNzYWdlIHdpdGggJ3Vuc3Vic2NyaWJlIGxpbnV4LW1tJyBpbjxicj4+IHRo
ZSBib2R5IHRvIG1ham9yZG9tb0BrdmFjay5vcmcuICBGb3IgbW9yZSBpbmZvIG9uIExpbnV4IE1N
LDxicj4+IHNlZTogPGEgaHJlZj0iaHR0cDovL3d3dy5saW51eC1tbS5vcmciPmh0dHA6Ly93d3cu
bGludXgtbW0ub3JnPC9hPi8gLjxicj4+IEZpZ2h0IHVuZmFpciB0ZWxlY29tIHBvbGljeSBpbiBD
YW5hZGE6IHNpZ24gPGEgaHJlZj0iaHR0cDovL2Rpc3NvbHZldGhlY3J0Yy5jYSI+aHR0cDovL2Rp
c3NvbHZldGhlY3J0Yy5jYTwvYT4vPGJyPj4gRG9uJ3QgZW1haWw6IDxhIGhyZWZtYWlsdG86ImRv
bnRAa3ZhY2sub3JnIj4gZW1haWxAa3ZhY2sub3JnIDwvYT48YnI+PGJyPjxicj48YnI+PC9ibG9j
a3F1b3RlPjwvYm9keT48L2h0bWw+DQo=


--Motorola-A-Mail-xe4FP56MXVvLz-1Y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
