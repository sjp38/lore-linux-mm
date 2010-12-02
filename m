Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 30D8F8D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 21:30:56 -0500 (EST)
Message-ID: <585ebcca-1e2f-496b-ad10-84b6f0f3e4fd@blur>
From: "Westerdale, John" <John.Westerdale@stryker.com>
Date: Wed, 1 Dec 2010 21:30:58 -0500
MIME-Version: 1.0
Subject: Re: Difference between CommitLimit and Comitted_AS?
References: <B13AEDEE265EDB4182EA8B932E33033D13A904B7@SOSEXCHCL02.howost.strykercorp.com> <20101202103408.1584.A69D9226@jp.fujitsu.com>
In-Reply-To: <20101202103408.1584.A69D9226@jp.fujitsu.com>
Content-Type: multipart/alternative;
	boundary="Motorola-A-Mail--JdOHCC3Qh1bR-ET";
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Motorola-A-Mail--JdOHCC3Qh1bR-ET
Content-Type: text/plain; Format="Flowed"; DelSp="Yes"; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Kosaki, 

Thanks for your contribution.

This system is only running 25 pct of projected load, so I am concerned. 

If we add up physical memory plus swap would that be a comfortable limit for  
committed_AS?

Can tomcat  (or whaever webshere uses for servelets) be tuned to allocate a  
fixed amount per session?  

as there are other applications on the same server, need to set up good  
fences.
 
can I use ulimits to exercise some rough level of control?

thanks

John

ps - sorry about the partial message :)
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





--Motorola-A-Mail--JdOHCC3Qh1bR-ET
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PGh0bWw+PGhlYWQ+PHN0eWxlIHR5cGU9InRleHQvY3NzIj5ib2R5IHt3b3JkLXdyYXA6IGJyZWFr
LXdvcmQ7IGJhY2tncm91bmQtY29sb3I6I2ZmZmZmZjt9PC9zdHlsZT48L2hlYWQ+PGJvZHk+PGRp
diBzdHlsZT0iZm9udC1mYW1pbHk6IHNhbnMtc2VyaWY7IGZvbnQtc2l6ZTogMTZweCI+S29zYWtp
LCA8YnI+PGJyPlRoYW5rcyBmb3IgeW91ciBjb250cmlidXRpb24uPGJyPjxicj5UaGlzIHN5c3Rl
bSBpcyBvbmx5IHJ1bm5pbmcgMjUgcGN0IG9mIHByb2plY3RlZCBsb2FkLCBzbyBJIGFtIGNvbmNl
cm5lZC4gPGJyPjxicj5JZiB3ZSBhZGQgdXAgcGh5c2ljYWwgbWVtb3J5IHBsdXMgc3dhcCB3b3Vs
ZCB0aGF0IGJlIGEgY29tZm9ydGFibGUgbGltaXQgZm9yIGNvbW1pdHRlZF9BUz88YnI+PGJyPkNh
biB0b21jYXQmbmJzcDsgKG9yIHdoYWV2ZXIgd2Vic2hlcmUgdXNlcyBmb3Igc2VydmVsZXRzKSBi
ZSB0dW5lZCB0byBhbGxvY2F0ZSBhIGZpeGVkIGFtb3VudCBwZXIgc2Vzc2lvbj8mbmJzcDsgPGJy
Pjxicj5hcyB0aGVyZSBhcmUgb3RoZXIgYXBwbGljYXRpb25zIG9uIHRoZSBzYW1lIHNlcnZlciwg
bmVlZCB0byBzZXQgdXAgZ29vZCBmZW5jZXMuPGJyPiA8YnI+Y2FuIEkgdXNlIHVsaW1pdHMgdG8g
ZXhlcmNpc2Ugc29tZSByb3VnaCBsZXZlbCBvZiBjb250cm9sPzxicj48YnI+dGhhbmtzPGJyPjxi
cj5Kb2huPGJyPjxicj5wcyAtIHNvcnJ5IGFib3V0IHRoZSBwYXJ0aWFsIG1lc3NhZ2UgOik8YnI+
PGZvbnQgY29sb3I9IiMzMzMzMzMiPjxpPjxzcGFuIHN0eWxlPSJmb250LXNpemU6IDE0cHgiPjxm
b250IGZhY2U9InNhbnMtc2VyaWYiPlNlbnQgdmlhIERST0lEIG9uIFZlcml6b24gV2lyZWxlc3M8
L2ZvbnQ+PC9zcGFuPjwvaT48L2ZvbnQ+PC9kaXY+PGJyPjxicj4tLS0tLU9yaWdpbmFsIG1lc3Nh
Z2UtLS0tLTxicj48YmxvY2txdW90ZSBzdHlsZT0iOyBib3JkZXItbGVmdDogMnB4IHNvbGlkIHJn
YigxNiwgMTYsIDI1NSk7IG1hcmdpbi1sZWZ0OiA1cHg7IHBhZGRpbmctbGVmdDogNXB4OyI+PGRp
diBzdHlsZT0iZm9udC1mYW1pbHk6IHNhbnMtc2VyaWY7IGZvbnQtc2l6ZTogMTRweCI+PGI+RnJv
bTogPC9iPktPU0FLSSBNb3RvaGlybyAmbHQ7a29zYWtpLm1vdG9oaXJvQGpwLmZ1aml0c3UuY29t
Jmd0OzxiPjxicj5UbzogPC9iPiZxdW90O1dlc3RlcmRhbGUsIEpvaG4mcXVvdDsgJmx0O0pvaG4u
V2VzdGVyZGFsZUBzdHJ5a2VyLmNvbSZndDs8Yj48YnI+Q2M6IDwvYj5rb3Nha2kubW90b2hpcm9A
anAuZnVqaXRzdS5jb20sIGxpbnV4LW1tQGt2YWNrLm9yZzxiPjxicj5TZW50OiA8L2I+VGh1LCBE
ZWMgMiwgMjAxMCAwMTo0MTowMyBHTVQrMDA6MDA8Yj48YnI+U3ViamVjdDogPC9iPlJlOiBEaWZm
ZXJlbmNlIGJldHdlZW4gQ29tbWl0TGltaXQgYW5kIENvbWl0dGVkX0FTPzxicj48YnI+PC9kaXY+
PiBIaSBBbGwsPGJyPj4gPGJyPj4gQW0gaW50ZXJlc3RlZCBpbiBkaWZmZXJlbnRpYXRpbmcgdGhl
IG1lYW5pbmcgb2YgQ29tbWl0KiBhbmQgVm1hbGxvYyouPGJyPj4gPGJyPj4gSSBoYWQgdGhvdWdo
dCB0aGF0IHRoZSBDb21taXR0ZWRfQVMgd2FzIHRoZSBzdW0gb2YgbWVtb3J5IGFsbG9jYXRpb25z
LDxicj4+IGFuZCBDb21taXRfTGltaXQgd2FzIHRoZSBhdmFpbGFibGUgbWVtb3J5IHRvIHNlcnZl
IHRoaXMgZnJvbS48YnI+PiA8YnI+PiBUaGF0IHNhaWQsIEkgd2luY2VkIHdoZW4gSSBzYXcgdGhh
dCBDb21taXR0ZWRfQVMgd2FzIGFsbW9zdCB0d2ljZSB0aGU8YnI+PiBDb21taXRfX0xpbWl0Ljxi
cj48YnI+Q29tbWl0X0xpbWl0IGlzIG9ubHkgbWVhbmluZ2Z1bCB3aGVuIG92ZXJjb21taXRfbWVt
b3J5PTIuPGJyPjxicj5BbmQsIExpbnV4IGhhcyB2aXJ0dWFsIG1lbW9yeSBmZWF0dXJlLiB0aGVu
IG1lbW9yeSBhbGxvY2F0aW9uIGhhcyAyIGxldmVscyw8YnI+dmlydHVhbCBhZGRyZXNzIHNwYWNl
IGFsbG9jYXRpb24gYW5kIHBoeXNpY2FsIG1lbW9yeSBhbGxvY2F0aW9uLjxicj5Db21taXR0ZWRf
QVMgbWVhbiBhbW91bnQgb2YgY29tbWl0dGVkIHZpcnR1YWwgYWRkcmVzcyBzcGFjZS4gSXQncyBu
b3Q8YnI+cGh5c2ljYWwuPGJyPjxicj5FeGFtcGxlLCBpZiB5b3UgY3JlYXRlIHRocmVhZCwgbGli
YyBhbGxvY2F0ZSBsb3RzIGFkZHJlc3Mgc3BhY2UgZm9yIHN0YWNrLjxicj5idXQgdHlwaWNhbCBw
cm9ncmFtIGRvbid0IHVzZSBzbyBsYXJnZSBzdGFjay4gdGhlbiBwaHlzaWNhbCBtZW1vcnkgd2ls
bCBiZSA8YnI+bm90IGFsbG9jYXRlZC48YnI+PGJyPjxicj4+IDxicj4+IFZtYWxsb2MgbG9va3Mg
aW5jb25zZXF1ZW50aWFsLCBidXQsIHRoZSBDb21taXQqIG51bWJlcnMgbXVzdCBiZSB0aGVyZTxi
cj4+IGZvciBhIHJlYXNvbi48YnI+PiA8YnI+PiBJcyBpdCBzYWZlIHRvIGNvbnRpbnVlIHJ1bm5p
bmcgd2l0aCBzdWNoIGEgcGVyY2VpdmVkIG92ZXItY29tbWl0Pzxicj48YnI+UHJvYmFibHkgc2Fm
ZS4gSmF2YSBydW50aW1lIHVzdWFsbHkgbWFrZXMgYSBsb3Qgb2Ygb3ZlcmNvbW1pdHMuIGJ1dCBJ
IGhhdmU8YnI+bm8gd2F5IHRvIGtub3cgZXhhY3RseSB5b3VyIHN5c3RlbSBzdGF0ZS4gPGJyPjxi
cj48YnI+PiA8YnI+PiBJcyB0aGlzIGV2aWRlbmNlIG9mIGEgbGVhayBvciBnYXJiYWdlIGNvbGxl
Y3Rpb24gaXNzdWVzPzxicj48YnI+TWF5YmUgbm8uPGJyPjxicj4+IDxicj4+IFRoaXMgc3lzdGVt
IGZ1bmN0aW9ucyBhcyBhbiBBcHAvV2ViIGZyb250IGVuZCB1c2luZyAgVG9tY2F0IHNlcnZlbGV0
PGJyPj4gZW5naW5lLCBGV0lXLjxicj4+IDxicj4+IFRoYW5rczxicj4+IDxicj4+IEpvaG4gV2Vz
dGVyZGFsZTxicj4+IDxicj4+IDxicj4+IE1lbVRvdGFsOiAgICAgMTY2MzQ0NjQga0I8YnI+PiBN
ZW1GcmVlOiAgICAgIDExMDc3NTIwIGtCPGJyPj4gQnVmZmVyczogICAgICAgIDQyMDc2OCBrQjxi
cj4+IENhY2hlZDogICAgICAgIDQzNzkwMDAga0I8YnI+PiBTd2FwQ2FjaGVkOiAgICAgICAgICAw
IGtCPGJyPj4gQWN0aXZlOiAgICAgICAgNDU3Nzk2MCBrQjxicj4+IEluYWN0aXZlOiAgICAgICA2
ODUzNDQga0I8YnI+PiBIaWdoVG90YWw6ICAgIDE1ODU5NDQwIGtCPGJyPj4gSGlnaEZyZWU6ICAg
ICAxMDk4NzYzMiBrQjxicj4+IExvd1RvdGFsOiAgICAgICA3NzUwMjQga0I8YnI+PiBMb3dGcmVl
OiAgICAgICAgIDg5ODg4IGtCPGJyPj4gU3dhcFRvdGFsOiAgICAgNDE5NDI5NiBrQjxicj4+IFN3
YXBGcmVlOiAgICAgIDQxOTQyOTYga0I8YnI+PiBEaXJ0eTogICAgICAgICAgICAgIDEyIGtCPGJy
Pj4gV3JpdGViYWNrOiAgICAgICAgICAgMCBrQjxicj4+IEFub25QYWdlczogICAgICA0NjI3NDgg
a0I8YnI+PiBNYXBwZWQ6ICAgICAgICAgIDY1NDIwIGtCPGJyPj4gU2xhYjogICAgICAgICAgIDI2
MDE0NCBrQjxicj4+IFBhZ2VUYWJsZXM6ICAgICAgMjE3MTIga0I8YnI+PiBORlNfVW5zdGFibGU6
ICAgICAgICAwIGtCPGJyPj4gQm91bmNlOiAgICAgICAgICAgICAgMCBrQjxicj4+IENvbW1pdExp
bWl0OiAgMTI1MTE1Mjgga0I8YnI+PiBDb21taXR0ZWRfQVM6IDIyNDIzMzU2IGtCPGJyPj4gVm1h
bGxvY1RvdGFsOiAgIDExNjcyOCBrQjxicj4+IFZtYWxsb2NVc2VkOiAgICAgIDY2MDAga0I8YnI+
PiBWbWFsbG9jQ2h1bms6ICAgMTA5NjEyIGtCPGJyPj4gSHVnZVBhZ2VzX1RvdGFsOiAgICAgMDxi
cj4+IEh1Z2VQYWdlc19GcmVlOiAgICAgIDA8YnI+PiBIdWdlUGFnZXNfUnN2ZDogICAgICAwPGJy
Pj4gSHVnZXBhZ2VzaXplOiAgICAgMjA0OCBrQgk8YnI+PiA8YnI+PiAtLTxicj4+IFRvIHVuc3Vi
c2NyaWJlLCBzZW5kIGEgbWVzc2FnZSB3aXRoICd1bnN1YnNjcmliZSBsaW51eC1tbScgaW48YnI+
PiB0aGUgYm9keSB0byBtYWpvcmRvbW9Aa3ZhY2sub3JnLiAgRm9yIG1vcmUgaW5mbyBvbiBMaW51
eCBNTSw8YnI+PiBzZWU6IDxhIGhyZWY9Imh0dHA6Ly93d3cubGludXgtbW0ub3JnIj5odHRwOi8v
d3d3LmxpbnV4LW1tLm9yZzwvYT4vIC48YnI+PiBGaWdodCB1bmZhaXIgdGVsZWNvbSBwb2xpY3kg
aW4gQ2FuYWRhOiBzaWduIDxhIGhyZWY9Imh0dHA6Ly9kaXNzb2x2ZXRoZWNydGMuY2EiPmh0dHA6
Ly9kaXNzb2x2ZXRoZWNydGMuY2E8L2E+Lzxicj4+IERvbid0IGVtYWlsOiA8YSBocmVmbWFpbHRv
OiJkb250QGt2YWNrLm9yZyI+IGVtYWlsQGt2YWNrLm9yZyA8L2E+PGJyPjxicj48YnI+PGJyPjwv
YmxvY2txdW90ZT48L2JvZHk+PC9odG1sPg0K


--Motorola-A-Mail--JdOHCC3Qh1bR-ET--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
